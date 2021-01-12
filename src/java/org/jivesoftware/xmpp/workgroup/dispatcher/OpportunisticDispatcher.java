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

import org.jivesoftware.xmpp.workgroup.*;
import org.jivesoftware.xmpp.workgroup.request.UserRequest;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.time.Duration;
import java.time.Instant;
import java.util.*;
import java.util.stream.Collectors;

/**
 * A dispatcher that offers a request to all available agents at the same time. The first agent to accept, 'wins'.
 *
 * @author Guus der Kinderen, guus@goodbytes.nl
 */
public class OpportunisticDispatcher extends AbstractDispatcher
{
    private static final Logger Log = LoggerFactory.getLogger(OpportunisticDispatcher.class);

    /**
     * Creates a new dispatcher for the queue. The dispatcher will have a Timer with a unique task
     * that will get the requests from the queue and will try to send an offer to the agents.
     *
     * @param queue the queue that contains the requests and the agents that may attend the
     *              requests.
     */
    public OpportunisticDispatcher(RequestQueue queue) {
        super(queue);
    }

    @Override
    protected void sendToAgent(final Offer offer, final Instant timeout, AgentSession initialAgent, AgentSession ignoreAgent)
    {
        final Set<AgentSession> eligibleAgents = getEligibleAgents(initialAgent, ignoreAgent, offer);
        if (eligibleAgents.isEmpty()) {
            Log.debug("No eligible agents available to receive offer for request: {}", offer.getRequest());
            return;
        }

        // Set the timeout of the offer based on the remaining time of the initial request and the default offer timeout
        offer.setTimeout(Math.min(Duration.between(timeout, Instant.now()).toMillis(), info.getOfferTimeout()));

        // Try to send the offer to all agents.
        final Set<AgentSession> offeredAgents = new HashSet<>();
        for( final AgentSession eligibleAgent : eligibleAgents ) {
            if (offer.getRequest().sendOffer(eligibleAgent, queue)) {
                Log.debug("Offer for request: {} SENT to agent: {}", offer.getRequest(), eligibleAgent.getJID());
                offeredAgents.add(eligibleAgent);
            } else {
                Log.debug("Offer for request: {} FAILED TO BE SENT to agent: {}", offer.getRequest(), eligibleAgent.getJID());
            }
        }

        // ... and now we wait...
        offer.waitForResolution();

        // If the offer was accepted, we send out the invites and reset the offer
        if (offer.isAccepted())
        {
            // Get the first agent that accepted the offer.
            AgentSession selectedAgent = offer.getAcceptedSessions().get(0);
            Log.debug("Offer for request: {} ACCEPTED BY agent: {}", offer.getRequest(), selectedAgent.getJID());

            // Create the room and send the invitations
            offer.invite(selectedAgent);

            // Notify the other agents tat accepted that the offer process has finished. Other pending sessions will
            // already have been notified.
            for (AgentSession offeredAgent : offeredAgents) {
                if (offeredAgent.equals(selectedAgent)) {
                    continue;
                }
                Log.debug("Offer for request: {} REVOKING from agent that also accepted: {}", offer.getRequest(), offeredAgent.getJID());
                offer.getRequest().sendRevoke(offeredAgent, queue);
                offeredAgent.removeOffer(offer);
            }

            if (offer.getRequest() instanceof UserRequest) {
                // Remove the user from the queue since his request has been accepted
                queue.removeRequest((UserRequest) offer.getRequest());
            }
        }
    }

    /**
     * Locate all agents eligible to receive an offer.
     *
     * Routing is based on show-status, max-chats, and who has already rejected the offer.
     * show status is ranked from most available to least: chat, default (no show status), away, and xa.
     *
     * A show status of dnd indicates no offers should be routed to an agent.
     *
     * The general algorithm to evaluate each agent is:
     * <ul>
     * <li>Skip if session is null. Should only occur if no agents are in the list.</li>
     * <li>Skip if session show state is DND. Never route to agents that are dnd.</li>
     * <li>Skip if session current-chats is equal to or higher than max-chats.</li>
     * <li>Skip if session has rejected this offer before.</li>
     * <ul>
     *
     * @param initialAgent the initial agent requested by the user.
     * @param ignoreAgent agent that should not be considered as available.
     * @param offer the offer about to be sent to the best available agent.
     * @return the best agent.
     */
    private Set<AgentSession> getEligibleAgents(AgentSession initialAgent, AgentSession ignoreAgent, Offer offer) {
        final Set<AgentSession> result;

        // Look for specified agent in agent list
        if (initialAgent != null) {
            Workgroup workgroup = offer.getRequest().getWorkgroup();
            if (initialAgent.isAvailableToChat() &&
                initialAgent.getCurrentChats(workgroup) < initialAgent.getMaxChats(workgroup)) {
                Log.debug("Initial agent: {} will receive offer for request: {}", initialAgent.getJID(), offer.getRequest());
                result = new HashSet<>();
                result.add(initialAgent);
                return result;
            }
        }

        // Let's iterate through each agent and check availability
        result = queue.getAgentSessionList().getAgentSessions().stream()
            .filter( agentSession -> !agentSession.equals(ignoreAgent))
            .filter( agentSession -> validateAgent(agentSession, offer) )
            .collect(Collectors.toSet());

        Log.debug("Found {} eligible agents to receive offer for request: {}", result.size(), offer.getRequest());
        return result;
    }
}
