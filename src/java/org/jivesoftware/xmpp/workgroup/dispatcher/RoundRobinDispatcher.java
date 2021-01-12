/*
 * Copyright (C) 2004-2008 Jive Software. All rights reserved.
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

import org.jivesoftware.xmpp.workgroup.*;
import org.jivesoftware.xmpp.workgroup.request.Request;
import org.jivesoftware.xmpp.workgroup.request.UserRequest;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.time.Duration;
import java.time.Instant;
import java.util.ArrayList;
import java.util.List;

/**
 * Implements simple round robin dispatching of offers to agents.
 * Agents are offered requests one at a time with no agent being offer
 * the same request twice (unless their current-chats status changes).
 *
 * @author Derek DeMoro
 * @author Iain Shigeoka
 */
public class RoundRobinDispatcher extends AbstractDispatcher {
    
    private static final Logger Log = LoggerFactory.getLogger(RoundRobinDispatcher.class);

    /**
     * Creates a new dispatcher for the queue. The dispatcher will have a Timer with a unique task
     * that will get the requests from the queue and will try to send an offer to the agents.
     *
     * @param queue the queue that contains the requests and the agents that may attend the
     *              requests.
     */
    public RoundRobinDispatcher(RequestQueue queue) {
        super(queue);
    }

    @Override
    protected void sendToAgent(final Offer offer, final Instant timeout, AgentSession initialAgent, AgentSession ignoreAgent)
    {
        Log.debug("Offer for request: {} Attempting to find best agent", offer.getRequest());
        final Request request = offer.getRequest();
        boolean canBeInQueue = request instanceof UserRequest;


        for (Duration timeRemaining = Duration.between(timeout, Instant.now());
             !offer.isAccepted() && !timeRemaining.isNegative() && !offer.isCancelled();) {
            try {
                AgentSession session = getBestNextAgent(initialAgent, ignoreAgent, offer);
                if (session == null && agentList.isEmpty()) {
                    // Stop looking for an agent since there are no more agent available
                     break;
                }
                else if (session == null || offer.isRejector(session)) {
                    initialAgent = null;
                    Thread.sleep(1000);
                }
                else {
                    // Recheck for changed maxchat setting
                    Workgroup workgroup = request.getWorkgroup();
                    if (session.getCurrentChats(workgroup) < session.getMaxChats(workgroup)) {
                        // Set the timeout of the offer based on the remaining time of the
                        // initial request and the default offer timeout
                        timeRemaining = Duration.between(timeout, Instant.now());
                        offer.setTimeout(Math.min(timeRemaining.toMillis(), info.getOfferTimeout()));

                        // Make the offer and wait for a resolution to the offer
                        if (!request.sendOffer(session, queue)) {
                            Log.debug("Offer for request: {} FAILED TO BE SENT to agent: {}", offer.getRequest(), session.getJID());
                            continue;
                        }
                        Log.debug("Offer for request: {} SENT to agent: {}", offer.getRequest(), session.getJID());

                        offer.waitForResolution();
                        // If the offer was accepted, we send out the invites
                        // and reset the offer
                        if (offer.isAccepted()) {
                            // Get the first agent that accepted the offer
                            AgentSession selectedAgent = offer.getAcceptedSessions().get(0);
                            Log.debug("Agent: {} ACCEPTED request: {}", selectedAgent.getJID(), request);
                            // Create the room and send the invitations
                            offer.invite(selectedAgent);
                            // Notify the agents that accepted the offer that the offer process
                            // has finished
                            for (AgentSession agent : offer.getAcceptedSessions()) {
                                agent.removeOffer(offer);
                            }
                            if (canBeInQueue) {
                                // Remove the user from the queue since his request has
                                // been accepted
                                queue.removeRequest((UserRequest) request);
                            }
                        }
                    }
                    else {
                        Log.debug("Selected agent: {} has reached max number of chats", session.getJID());
                    }
                }
            }
            catch (Exception e) {
                Log.error("An unexpected exception occurred while dispatching offer: {}", offer, e);
            }
        }
    }

    /**
     * Locate the next 'best' agent to receive an offer.
     * Routing is based on show-status, max-chats, and who has
     * already rejected the offer.
     * show status is ranked from most available to least:
     * chat, default (no show status), away,
     * and xa. A show status of dnd indicates no offers should be routed to an agent.
     * The general algorithm is:
     * <ul>
     * <li>Mark the current position.</li>
     * <li>Start iterating around the circular queue until all agents
     * have been considered. For each agent:
     * <ul>
     * <li>Skip if session is null. Should only occur if no agents are in the list.</li>
     * <li>Skip if session show state is DND. Never route to agents that are dnd.</li>
     * <li>Skip if session current-chats is equal to or higher than max-chats.</li>
     * <li>Replace current best if:
     * <ul>
     * <li>No current best. Any agent is better than none.</li>
     * <li>If session hasn't rejected offer but current best has.</li>
     * <li>If both session and current best have not rejected the
     * offer and session show-status is higher.</li>
     * <li>If both session and current best have rejected offer and
     * session show-status is higher.</li>
     * </ul></li>
     * </ul></li>
     * </li>
     *
     * @param initialAgent the initial agent requested by the user.
     * @param ignoreAgent agent that should not be considered as available.
     * @param offer the offer about to be sent to the best available agent.
     * @return the best agent.
     */
    private AgentSession getBestNextAgent(AgentSession initialAgent, AgentSession ignoreAgent, Offer offer)
    {
        Log.debug("Agent selection for receiving offer for request: {}", offer.getRequest());

        // Look for specified agent in agent list
        if (initialAgent != null) {
            Log.trace("Initial agent specified: {}", initialAgent.getJID());
            Workgroup workgroup = offer.getRequest().getWorkgroup();
            if (initialAgent.isAvailableToChat() &&
                initialAgent.getCurrentChats(workgroup) < initialAgent.getMaxChats(workgroup)) {
                Log.debug("Initial agent: {} will receive offer for request: {}", initialAgent.getJID(), offer.getRequest());
                return initialAgent;
            }
        }

        // Let's iterate through each agent and check availability
        final AgentSessionList agentSessionList = queue.getAgentSessionList();
        final List<AgentSession> possibleSessions = new ArrayList<>();
        for (AgentSession agentSession : agentSessionList.getAgentSessions()) {
            if (agentSession.equals(ignoreAgent)) {
                Log.trace("Ignoring agent: {}", agentSession.getJID());
                continue;
            }

            if (validateAgent(agentSession, offer)) {
                possibleSessions.add(agentSession);
                Log.trace("Considering agent: {}", agentSession.getJID());
            } else {
                Log.trace("Not considering agent: {}", agentSession.getJID());
            }
        }

        // Select the best agent from the list of possible agents
        if (possibleSessions.size() > 0) {
            AgentSession s = agentSelector.bestAgentFrom(possibleSessions, offer);
            Log.trace("Agent SELECTED: {} for receiving offer for request: {}", s.getJID(), offer.getRequest());
            return s;
        }

        Log.debug("Unable to select agent for receiving offer for request: {}", offer.getRequest());
        return null;
    }
}
