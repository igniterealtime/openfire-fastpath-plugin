/*
 * Copyright (C) 2004-2006 Jive Software. All rights reserved.
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

import org.jivesoftware.xmpp.workgroup.UnauthorizedException;
import org.jivesoftware.xmpp.workgroup.Workgroup;

import java.time.Duration;

/**
 * <p>A basic, 'pure data structure' implementation of the dispatcher info interface.
 *
 * @author Derek DeMoro
 */
public class BasicDispatcherInfo implements DispatcherInfo {

    private long id;
    private String name;
    private String description;
    private Workgroup workgroup;
    private Duration offerTimeout;
    private Duration requestTimeout;

    public BasicDispatcherInfo(
            Workgroup workgroup,
            long id,
            String name,
            String description,
            Duration offerTimeout,
            Duration requestTimeout) {
        this.workgroup = workgroup;
        this.id = id;
        this.name = name;
        this.description = description;
        this.offerTimeout = offerTimeout;
        this.requestTimeout = requestTimeout;
    }


    public long getId() {
        return id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) throws UnauthorizedException {
        this.name = name;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) throws UnauthorizedException {
        this.description = description;
    }

    public void setRequestTimeout(Duration timeout) {
        requestTimeout = timeout;
    }

    public Duration getRequestTimeout() {
        if (requestTimeout.isNegative()) {
            return workgroup.getRequestTimeout();
        }
        return requestTimeout;
    }

    public void setOfferTimeout(Duration timeout) {
        offerTimeout = timeout;
    }

    public Duration getOfferTimeout() {
        if (offerTimeout.isNegative()) {
            return workgroup.getOfferTimeout();
        }
        return offerTimeout;
    }


}
