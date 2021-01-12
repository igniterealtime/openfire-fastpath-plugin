/*
 * Copyright (C) 2021 Ignite Realtime Foundation. All rights reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package org.jivesoftware.xmpp.workgroup.dispatcher;

import org.jivesoftware.openfire.fastpath.util.TaskEngine;
import org.jivesoftware.openfire.fastpath.util.WorkgroupUtils;
import org.jivesoftware.util.BeanUtils;
import org.jivesoftware.util.ClassUtils;
import org.jivesoftware.util.JiveGlobals;
import org.jivesoftware.util.NotFoundException;
import org.jivesoftware.xmpp.workgroup.*;
import org.jivesoftware.xmpp.workgroup.request.Request;
import org.jivesoftware.xmpp.workgroup.request.UserRequest;
import org.jivesoftware.xmpp.workgroup.spi.JiveLiveProperties;
import org.jivesoftware.xmpp.workgroup.spi.dispatcher.DbDispatcherInfoProvider;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.time.Duration;
import java.time.Instant;
import java.util.*;
import java.util.concurrent.ConcurrentHashMap;

/**
 * Provides re-usable functionality for implementing Dispatchers.
 *
 * @author Guus der Kinderen, guus@goodbytes.nl
 */
public abstract class AbstractDispatcher implements Dispatcher, AgentSessionListener {

    private static final Logger Log = LoggerFactory.getLogger(AbstractDispatcher.class);

    /**
     * The circular list of agents in the pool.
     */
    protected final List<AgentSession> agentList;
    protected final RequestQueue queue;

    /**
     * Prop manager for the dispatcher.
     */
    protected final JiveLiveProperties properties;
    protected final DispatcherInfoProvider infoProvider = new DbDispatcherInfoProvider();

    /**
     * A set of all outstanding offers in the workgroup
     *
     * Let's the server route offer responses to the correct offer.
     */
    private final Set<Offer> offers = Collections.newSetFromMap(new ConcurrentHashMap<>());
    protected DispatcherInfo info;
    protected AgentSelector agentSelector = WorkgroupUtils.getAvailableAgentSelectors().get(0);

    /**
     * Creates a new dispatcher for the queue. The dispatcher will have a Timer with a unique task
     * that will get the requests from the queue and will try to send an offer to the agents.
     *
     * @param queue the queue that contains the requests and the agents that may attend the
     *        requests.
     */
    public AbstractDispatcher(RequestQueue queue) {
        agentList = new LinkedList<>();
        this.queue = queue;
        properties = new JiveLiveProperties("fpDispatcherProp", queue.getID());

        try {
            info = infoProvider.getDispatcherInfo(queue.getWorkgroup(), queue.getID());
        }
        catch (NotFoundException e) {
            Log.error("Queue ID " + queue.getID(), e);
        }
        // Recreate the agentSelector to use for selecting the best agent to receive the offer
        loadAgentSelector();

        // Fill the list of AgentSessions that are active in the queue.  Once the list has been
        // filled this dispatcher will be notified when new AgentSessions join the queue or leave
        // the queue
        fillAgentsList();

        TaskEngine.getInstance().scheduleAtFixedRate(new TimerTask() {
            @Override
            public void run() {
                checkForNewRequests();
            }
        }, 2000, 2000);
    }

    /**
     * Returns a child property names given a parent and an Iterator of property names.
     *
     * @param parent     parent property name.
     * @param properties all property names to search.
     * @return an Iterator of child property names.
     */
    private static Collection<String> getChildrenPropertyNames(String parent, Collection<String> properties) {
        List<String> results = new ArrayList<>();
        for (String name : properties) {
            if (name.startsWith(parent) && !name.equals(parent)) {
                results.add(name);
            }
        }
        return results;
    }

    protected void checkForNewRequests() {
        for (Request request : queue.getRequests()) {
            // While there are requests pending try to dispatch an offer for the request to an agent
            // Skip this request if there exists an offer for this requests that is being processed
            if (request.getOffer() != null && offers.contains(request.getOffer())) {
                continue;
            }
            injectRequest(request);
        }
    }

    @Override
    public void injectRequest(Request request) {
        // Create a new Offer for the request and add it to the list of active offers
        final Offer offer = new Offer(request, queue, getAgentRejectionTimeout());
        offer.setTimeout(info.getOfferTimeout());
        offers.add(offer);
        // Process this offer in another thread
        Thread offerThread = new Thread("Dispatch offer - queue: " + queue.getName()) {
            @Override
            public void run() {
                dispatch(offer);
                // Remove this offer from the list of active offers
                offers.remove(offer);
            }
        };
        offerThread.start();
    }

    /**
     * Dispatch the given request to one or more agents in the agent pool.
     *
     * If this method returns, it is assumed that the request was properly
     * dispatched. The only exception is if an agent is not in the pool for routing
     * within the agent timeout period, the dispatch will throw an AgentNotFoundException
     * so the request can be re-routed.
     *
     * @param offer the offer to send to the best agent available.
     */
    public final void dispatch(Offer offer)
    {
        Log.debug("Dispatching request: {} in queue: {}", offer.getRequest(), queue.getAddress());

        final Request request = offer.getRequest();
        boolean canBeInQueue = request instanceof UserRequest;

        // Send the offer to the best agent. While the offer has not been accepted send it to the
        // next best agent. If there aren't any agent available then skip this section and proceed
        // to overflow the current request
        if (!agentList.isEmpty()) {
            // The time when the request should timeout.
            final Instant timeout = Instant.now().plus(Duration.ofMillis(info.getRequestTimeout()));

            final Map<String, List<String>> map = request.getMetaData();
            final String initialAgent = map.get("agent") == null || map.get("agent").isEmpty() ? null : map.get("agent").get(0);
            final String ignoreAgent = map.get("ignore") == null || map.get("ignore").isEmpty() ? null : map.get("ignore").get(0);

            sendToAgent(offer, timeout, findAgentSessionByName(initialAgent).orElse(null), findAgentSessionByName(ignoreAgent).orElse(null));
        } else {
            Log.debug("Agent list is empty. Cannot send to request: {} in queue: {} to any of its agents.", request, queue.getAddress());
        }

        if (!offer.isAccepted() && !offer.isCancelled()) {
            // Calculate the maximum time limit for an unattended request before cancelling it
            final Instant limit = request.getCreationTime().toInstant().plus( Duration.ofMillis( info.getRequestTimeout() * (getOverflowTimes() + 1) ) );
            if (!Instant.now().isAfter(limit) || !canBeInQueue) {
                Log.debug("Cancelling request that maxed out overflow limit or cannot be queued: {}", request);
                // Cancel the request if it has overflowed 'n' times
                request.cancel(Request.CancelType.AGENT_NOT_FOUND);
            }
            else {
                // Overflow if request timed out and was not dispatched and max number of overflows has not been reached yet
                overflow(offer);
                // If there is no other queue to overflow then cancel the request
                if (!offer.isAccepted() && !offer.isCancelled()) {
                    Log.debug("Cancelling request that didn't overflow: {}", request);
                    request.cancel(Request.CancelType.AGENT_NOT_FOUND);
                }
            }
        }
    }

    /**
     * Sends an offer to the best agent available.
     *
     * @param offer the offer to send to the best agent available.
     * @param timeout The time when the request should timeout.
     * @param initialAgent An optional preferred agent.
     * @param ignoreAgent An optional agent to be ignored.
     */
    protected abstract void sendToAgent(final Offer offer, final Instant timeout, final AgentSession initialAgent, final AgentSession ignoreAgent);

    /**
     * Overflow the current request into another queue if possible.
     *
     * Future versions of the dispatcher may wish to overflow in
     * more sophisticated ways. Currently we do it according to overflow
     * rules: none (no overflow), backup (to a backup if it exists and is
     * available, or randomly.
     *
     * @param offer the offer to place in the overflow queue.
     */
    protected void overflow(Offer offer) {
        RequestQueue backup = null;
        if (RequestQueue.OverflowType.OVERFLOW_BACKUP.equals(queue.getOverflowType())) {
            backup = queue.getBackupQueue();
            // Check that the backup queue has agents available otherwise discard it
            if (backup != null && !backup.getAgentSessionList().containsAvailableAgents()) {
                backup = null;
            }
        } else if (RequestQueue.OverflowType.OVERFLOW_RANDOM.equals(queue.getOverflowType())) {
            backup = getRandomQueue();
        }
        // If a backup queue was found then cancel this offer, remove the request from the queue
        // and add the request in the backup queue
        if (backup != null) {
            offer.cancel();
            UserRequest request = (UserRequest) offer.getRequest();
            // Remove the request from the queue since it is going to be added to another queue
            queue.removeRequest(request);
            // Log debug trace
            Log.debug("Overflowing request: {} to queue: {}", request, backup.getAddress());
            backup.addRequest(request);
        }
    }

    /**
     * Returns a queue that was randomly selected.
     *
     * @return a queue that was randomly selected.
     */
    private RequestQueue getRandomQueue() {
        int qCount = queue.getWorkgroup().getRequestQueueCount();
        if (qCount > 1) {
            // Build a list of all queues eligible for overflow
            LinkedList<RequestQueue> overflowQueueList = new LinkedList<>();
            for (RequestQueue overflowQueue : queue.getWorkgroup().getRequestQueues()) {
                if (!queue.equals(overflowQueue) && overflowQueue.getAgentSessionList().containsAvailableAgents()) {
                    overflowQueueList.addLast(overflowQueue);
                }
            }

            // If there are any eligible queues
            if (overflowQueueList.size() > 0) {
                // choose the random index of the overflow queue to use
                int targetIndex = (int) Math.floor(((float) (overflowQueueList.size())) * Math.random());
                if (targetIndex < overflowQueueList.size()) {
                    return overflowQueueList.get(targetIndex);
                }
            }
        }
        return null;
    }

    /**
     * Generate the agents offer list.
     */
    protected void fillAgentsList() {
        AgentSessionList agentSessionList = queue.getAgentSessionList();
        agentSessionList.addAgentSessionListener(this);
        for (AgentSession agentSession : agentSessionList.getAgentSessions()) {
            if (!agentList.contains(agentSession)) {
                agentList.add(agentSession);
            }
        }
    }

    /**
     * Returns true if the agent session may receive an offer. An agent session may receive new
     * offers if:
     *
     * 1) the presence status of the agent allows to receive offers
     * 2) the maximum of chats has not been reached for the agent
     * 3) the agent has not rejected the offer before
     * 4) the agent does not have to answer a previous offer
     *
     * @param session the session to check if it may receive an offer
     * @param offer the offer to send.
     * @return true if the agent session may receive an offer.
     */
    protected boolean validateAgent(AgentSession session, Offer offer) {
        if (agentSelector.validateAgent(session, offer)) {
            Log.debug("Validated Agent: {} MAY receive offer for request: {}", session.getJID(), offer.getRequest());
            return true;
        } else {
            Log.debug("Cold not validate Agent: {} MAY NOT receive offer for request: {}", session.getJID(), offer.getRequest());
            return false;
        }
    }

    /**
     * Returns the max number of times a request may overflow. Once the request has exceeded this
     * number it will be cancelled. This limit avoids infinite overflow loops.
     *
     * @return the max number of times a request may overflow.
     */
    public long getOverflowTimes() {
        return JiveGlobals.getIntProperty("xmpp.live.request.overflow", 3);
    }

    /**
     * Returns the number of milliseconds to wait until expiring an agent rejection.
     *
     * @return the number of milliseconds to wait until expiring an agent rejection.
     */
    public long getAgentRejectionTimeout() {
        return JiveGlobals.getIntProperty("xmpp.live.rejection.timeout", 20000);
    }

    @Override
    public void notifySessionAdded(AgentSession session) {
        if (!agentList.contains(session)) {
            agentList.add(session);
        }
    }

    @Override
    public void notifySessionRemoved(AgentSession session) {
        agentList.remove(session);
        for (Offer offer : offers) {
            offer.reject(session);
        }
    }

    @Override
    public DispatcherInfo getDispatcherInfo() {
        return info;
    }

    @Override
    public void setDispatcherInfo(DispatcherInfo info) throws UnauthorizedException {
        try {
            infoProvider.updateDispatcherInfo(queue.getID(), info);
            this.info = info;
        } catch (NotFoundException | UnsupportedOperationException e) {
            Log.error("An unexpected exception occurred while setting dispatcher info: {}", info, e);
        }
    }

    @Override
    public int getOfferCount() {
        return offers.size();
    }

    @Override
    public Iterator<Offer> getOffers() {
        return offers.iterator();
    }

    @Override
    public Iterator<Offer> getOffers(WorkgroupResultFilter filter) {
        return filter.filter(offers.iterator());
    }

    @Override
    public String getProperty(String name) {
        return properties.getProperty(name);
    }

    @Override
    public void setProperty(String name, String value) throws UnauthorizedException {
        properties.setProperty(name, value);
    }

    @Override
    public void deleteProperty(String name) throws UnauthorizedException {
        properties.deleteProperty(name);
    }

    @Override
    public Collection<String> getPropertyNames() {
        return properties.getPropertyNames();
    }

    @Override
    public AgentSelector getAgentSelector() {
        return agentSelector;
    }

    @Override
    public void setAgentSelector(AgentSelector agentSelector) {
        this.agentSelector = agentSelector;
        // Delete all agentSelector properties.
        try {
            for (String property : getPropertyNames()) {
                if (property.startsWith("agentSelector")) {
                    deleteProperty(property);
                }
            }
        } catch (Exception e) {
            Log.error("An unexpected exception occurred while setting agent selector: {}", agentSelector, e);
        }
        // Save the agentSelector as a property of the dispatcher
        try {
            Map<String, String> propertyMap = getPropertiesMap(agentSelector, "agentSelector.");
            for (Map.Entry<String, String> entry : propertyMap.entrySet()) {
                setProperty(entry.getKey(), entry.getValue());
            }
        } catch (Exception e) {
            Log.error("An unexpected exception occurred while saving agent selector as a property of the dispatcher: {}", agentSelector, e);
        }
    }

    private Map<String, String> getPropertiesMap(AgentSelector agentSelector, String context) {
        // Build the properties map that will be saved later
        Map<String, String> propertyMap = new HashMap<>();
        // Write out class name
        propertyMap.put(context + "className", agentSelector.getClass().getName());

        // Write out all properties
        Map<String, String> props = BeanUtils.getProperties(agentSelector);
        for (Map.Entry<String, String> entry : props.entrySet()) {
            String name = entry.getKey();
            String value = entry.getValue();
            if (value != null && !"".equals(value)) {
                propertyMap.put(context + "properties." + name, value);
            }
        }
        return propertyMap;
    }

    protected void loadAgentSelector() {
        try {
            String context = "agentSelector.";
            String className = getProperty(context + "className");
            if (className == null) {
                // Do nothing and use the BasicAgentSelector
                return;
            }
            Class<?> agentSelectorClass = loadClass(className);
            agentSelector = (AgentSelector) agentSelectorClass.newInstance();

            // Load properties.
            Collection<String> props = AbstractDispatcher.getChildrenPropertyNames(context + "properties", getPropertyNames());
            Map<String, String> agentSelectorProps = new HashMap<>();

            for (String key : props) {
                String value = getProperty(key);
                // Get the bean property name, which is everything after the last '.' in the xml property name.
                agentSelectorProps.put(key.substring(key.lastIndexOf(".") + 1), value);
            }

            // Set properties on the bean
            BeanUtils.setProperties(agentSelector, agentSelectorProps);
        } catch (Exception e) {
            Log.error("An unexpected exception occurred while loading an agent selector.", e);
        }
    }

    private Class<?> loadClass(String className) throws ClassNotFoundException {
        try {
            return ClassUtils.forName(className);
        } catch (ClassNotFoundException e) {
            return this.getClass().getClassLoader().loadClass(className);
        }
    }

    @Override
    public void shutdown() {
        for (final Offer offer : offers) {
            offer.cancel();
        }
    }

    /**
     * Returns an agent session by name of the agent, if that agent currently has a session.
     *
     * @param name The name of the agent.
     * @return An optional of the agent session.
     */
    public Optional<AgentSession> findAgentSessionByName(final String name) {
        return queue.getAgentSessionList().getAgentSessions().stream()
            .filter( agentSession -> agentSession.getAgent().getAgentJID().toBareJID().startsWith(name.toLowerCase()))
            .findFirst();
    }
}
