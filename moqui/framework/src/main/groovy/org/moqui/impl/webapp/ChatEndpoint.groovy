/*
 * This software is in the public domain under CC0 1.0 Universal plus a
 * Grant of Patent License.
 *
 * To the extent possible under law, the author(s) have dedicated all
 * copyright and related and neighboring rights to this software to the
 * public domain worldwide. This software is distributed without any
 * warranty.
 *
 * You should have received a copy of the CC0 Public Domain Dedication
 * along with this software (see the LICENSE.md file). If not, see
 * <http://creativecommons.org/publicdomain/zero/1.0/>.
 */
package org.moqui.impl.webapp

import groovy.transform.CompileStatic
import org.slf4j.Logger
import org.slf4j.LoggerFactory
import groovy.json.*
import org.moqui.impl.context.ExecutionContextImpl
import org.moqui.entity.*
import org.moqui.util.*

import javax.websocket.CloseReason
import javax.websocket.EndpointConfig
import javax.websocket.Session
import javax.websocket.EncodeException;
import javax.websocket.EncodeException;


import java.io.IOException;
import java.util.HashMap;
import java.util.Set;
import java.util.concurrent.CopyOnWriteArraySet;

@CompileStatic
class ChatEndpoint extends MoquiAbstractEndpoint {
    private final static Logger logger = LoggerFactory.getLogger(ChatEndpoint.class)

    private static final Set<ChatEndpoint> chatEndpoints = new CopyOnWriteArraySet<>();
    private static HashMap<String, String> users = new HashMap<>();
    private static HashMap<String, String> usersApiKey = new HashMap<>();
    private static HashMap<String, String> usersToken = new HashMap<>();

    Logger logger = LoggerFactory.getLogger(ChatEndpoint.class);
    ExecutionContextImpl ec
    String apiKey,userid,moquiSessionToken
    Map result

    @Override
    void onOpen(Session session, EndpointConfig config) {
        this.destroyInitialEci = false
        super.onOpen(session, config)
        logger.info("====parameters: ${session.getRequestParameterMap()}")
        logger.info("New connection request received sessionId: ${session.getId()}  for user ${userId}:${username}");
        ec = ecf.getEci()
        Map<String,List<String>> params = session.getRequestParameterMap()
        apiKey = params.get("apiKey")[0]
        userId = params.get("userId")[0]
        logger.info("===apikey: $apiKey  userId: $userId")
        RestClient restClient = ec.service.rest().method(RestClient.GET)
                .uri("http://localhost:8080/rest/s1/growerp/100/Authenticate?classificationId=chat")
                .addHeader("Content-Type", "application/json")
                .addHeader("api_key", "${apiKey}")
        RestClient.RestResponse restResponse = restClient.call()
        result = (Map) restResponse.jsonObject()
        logger.info("===result of auth check: $result")
        if (restResponse.statusCode < 200 || restResponse.statusCode >= 300 ) {
            ec.logger.warn("====Unsuccessful val result: ${result}")
            return
        }
        Map auth = (Map) result.authenticate
        moquiSessionToken = (String) auth.moquiSessionToken

        this.session = session;
        chatEndpoints.add(this);
        users.put(session.getId(), userId);
        usersApiKey.put(session.getId(), apiKey);
        usersToken.put(session.getId(), moquiSessionToken);

    }

    @Override
    void onMessage(String messageJson)
            throws IOException, EncodeException {
        Map message = (Map) new JsonSlurper().parseText(messageJson)
        logger.info("receiving uid: ${getUserId()} message from:" + message.fromUserId + 
                    " to: " + message.toUserId +
                    " content: " + message.content +
                    " chatRoomId: " + message.chatRoomId);
        message.fromUserId = users.get(session.getId());

        chatEndpoints.forEach(endpoint -> {
            if (users.get(endpoint.session.getId()).equals(message.toUserId)) {

                synchronized (endpoint) {
                    try {
                        logger.info("Sending chatmessage: " + message.content +
                                " to: " + message.oUserId + " sessionId:" + 
                            endpoint.session.getId());
                        endpoint.session.asyncRemote.sendText(JsonOutput.toJson(message))
                    } catch (IOException | EncodeException e) {
                        logger.info("chat message send failed....");
                    }
                }
            }
        });
    }

    @Override
    void onClose(Session session, CloseReason closeReason) throws IOException, EncodeException {
        logger.info("closing websocket for user:" + session.getId());
        users.remove(session.getId());
        chatEndpoints.remove(this);
        Map message = [
            "fromUserId": users.get(session.getId()),
            "content": "Disconnected!"];
        broadcast(JsonOutput.toJson(message));
        super.onClose(session, closeReason)
    }

    private static void broadcast(String message) throws IOException, EncodeException {
        Logger logger = LoggerFactory.getLogger(ChatEndpoint.class);
        chatEndpoints.forEach(endpoint -> {
            synchronized (endpoint) {
                try {
                    logger.info("chat broadcast message send: $message...");
                    endpoint.session.getBasicRemote()
                        .sendObject(message);
                } catch (IOException | EncodeException e) {
                    logger.info("chat broadcast message send failed....");
                }
            }
        });
    }
}

