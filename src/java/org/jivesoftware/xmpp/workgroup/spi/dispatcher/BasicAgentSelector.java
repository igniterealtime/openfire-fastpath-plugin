package org.jivesoftware.xmpp.workgroup.spi.dispatcher;

import org.jivesoftware.xmpp.workgroup.AgentSession;
import org.jivesoftware.xmpp.workgroup.Offer;
import org.jivesoftware.xmpp.workgroup.Workgroup;
import org.jivesoftware.xmpp.workgroup.dispatcher.AgentSelector;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.Collections;
import java.util.Comparator;
import java.util.List;

/**
 * Basic implementation that uses the following condition for selecting possible agents:
 * <ul>
 * <li>the presence status of the agent allows to receive offers</li>
 * <li>the maximum of chats has not been reached for the agent</li>
 * <li>the agent has not rejected the offer before</li>
 * <li>the agent does not have to answer a previuos offer</li>
 * </ul>
 * <p/>
 * And the best agent will be the one with less number of chats. If more than one agent has
 * the less number of chats then the agent that never rejected the offer will be selected.
 *
 * @author Gaston Dombiak
 */
public class BasicAgentSelector implements AgentSelector {

    private static final Logger Log = LoggerFactory.getLogger(BasicAgentSelector.class);

    /**
     * Returns true if the agent session may receive an offer. An agent session may receive new
     * offers if:
     * <p/>
     * 1) the presence status of the agent allows to receive offers
     * 2) the maximum of chats has not been reached for the agent
     * 3) the agent has not rejected the offer before
     * 4) the agent does not have to answer a previous offer
     */
    public boolean validateAgent(AgentSession session, Offer offer) {
        Workgroup workgroup = offer.getRequest().getWorkgroup();
        final boolean agentSessionExists = session != null;
        final boolean isAvailableToChat = session != null && session.isAvailableToChat();
        final boolean doesntHaveToManyChats =  session != null && session.getCurrentChats(workgroup) < session.getMaxChats(workgroup);
        final boolean hasNotPreviouslyRejectedThisOffer = session != null && !offer.isRejector(session);
        final boolean shouldNotAnswerPreviousOfferFirst = session != null && !session.isWaitingOfferAnswer();

        final boolean result = agentSessionExists && isAvailableToChat && doesntHaveToManyChats && hasNotPreviouslyRejectedThisOffer && shouldNotAnswerPreviousOfferFirst;
        Log.trace("Agent {} session exists: {}", session == null ? "NULL" : session.getJID(), agentSessionExists);
        Log.trace("Agent {} is available to chat: {}", session == null ? "NULL" : session.getJID(), isAvailableToChat);
        Log.trace("Agent {} doesn't have to many existing chats: {}", session == null ? "NULL" : session.getJID(), doesntHaveToManyChats);
        Log.trace("Agent {} has not previously rejected this offer: {}", session == null ? "NULL" : session.getJID(), hasNotPreviouslyRejectedThisOffer);
        Log.trace("Agent {} does not have to answer a previous offer first: {}", session == null ? "NULL" : session.getJID(), shouldNotAnswerPreviousOfferFirst);
        Log.debug("Agent {} may receive offer for request: {}? {} (reasoning logged on level TRACE).", new Object[] {session == null ? "NULL" : session.getJID(), offer.getRequest(), result});
        return result;
    }

    /**
     * The best agent will be the agent with less number of chats. If more than one agent has
     * the less number of chats then select the agent that never rejected the offer.
     */
    public AgentSession bestAgentFrom(List<AgentSession> possibleSessions, Offer offer) {
        Collections.sort(possibleSessions, new SessionComparator(offer));
        int size = possibleSessions.size() - 1;
        return possibleSessions.get(size);
    }

    /**
     * Sort/compare the AgentSessions based on the number of current chats. But if the number of
     * chats is equal then sort/compare based on previous rejections of the offer.
     */
    private class SessionComparator implements Comparator<AgentSession> {

        private Offer offer;

        public SessionComparator(Offer offer) {
            super();
            this.offer = offer;
        }

        public int compare(AgentSession item1, AgentSession item2) {
            Workgroup workgroup = offer.getRequest().getWorkgroup();
            int int1 = item1.getCurrentChats(workgroup);
            int int2 = item2.getCurrentChats(workgroup);

            if (int1 == int2) {
                // Base the decision on previous offer rejections
                int rejec1 = offer.getRejections().contains(item1.getJID().toBareJID()) ? 1 : 0;
                int rejec2 = offer.getRejections().contains(item2.getJID().toBareJID()) ? 1 : 0;

                if (rejec1 == rejec2) {
                    long time1 = item1.getTimeLastChatEnded() == null ? 0 : item1.getTimeLastChatEnded().getTime();
                    long time2 = item2.getTimeLastChatEnded() == null ? 0 : item2.getTimeLastChatEnded().getTime();

                    if (time1 == time2) {
                        return 0;
                    }

                    if (time1 > time2) {
                        return -1;
                    }

                    if (time1 < time2) {
                        return 1;
                    }

                }
                else if (rejec1 > rejec2) {
                    return -1;
                }
                else {
                    return 1;
                }
            }

            if (int1 > int2) {
                return -1;
            }

            if (int1 < int2) {
                return 1;
            }

            return 0;
        }
    }


}
