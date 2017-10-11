// cometdCustom

var cometdCustom = function() {
    return {
        cometdDisconnect : function(cometd) {
            console.log(' cometdDisconnect ');
            if (cometd) {
                cometd.removeListener(metaConnectListener);
                cometd.removeListener(metaDisconnectListener);
                cometd.removeListener(metaHandshakeListener);
                cometd.removeListener(metaSubscribeListener);
                cometd.removeListener(metaUnSubscribeListener);
                cometd.unsubscribe(subscribedToChannel);
                cometd.disconnect();
            }
        },
        cometdConnect : function(url, sessionId, channel, relayFrom, onMessageListener, subscribeListener, unsubscribeListener, connectListener, disconnectListener, handshakeListener, unsuccessfulListener) {
            console.log(' cometdConnect url ' + url + ' sessionId ' + sessionId + ' channel ' + channel  );

            var cometd = $.cometd;

            var replayExtension = new cometdReplayExtension();
            replayExtension.setChannel(channel);
            replayExtension.setReplay(relayFrom);
            replayExtension.setExtensionEnabled(true);
            cometd.registerExtension('replayFrom', replayExtension);

            cometd.addListener('/meta/connect', function(message) {
                if (cometd.isDisconnected()) {
                    console.log('cometd not connected throwing error ');
                    throw "cometd not connected throwing error";
                }
                if ( connectListener ) { connectListener(message); }
            });

            if(disconnectListener) { cometd.addListener('/meta/disconnect', disconnectListener ) };
            cometd.addListener('/meta/handshake', function(message) {
                if( onMessageListener ) { cometd.subscribe( channel, onMessageListener ); }
                if( handshakeListener ) { handshakeListener(message); }
            } );

            if( subscribeListener ) { cometd.addListener('/meta/subscribe', subscribeListener); }
            if( unsubscribeListener ) { cometd.addListener('/meta/unsubscribe', unsubscribeListener ); }
            if( unsuccessfulListener ) { cometd.addListener('/meta/unsuccessful', unsuccessfulListener ); }

            cometd.websocketEnabled = false;
            cometd.configure({
                url: url,
                requestHeaders: { Authorization: 'OAuth ' + sessionId }
            });
            cometd.handshake();
            return cometd;
        },
        cometdURL : function(version) {
            var loc = window.location;
            var baseUrl = loc.protocol + "//" + loc.hostname + (loc.port? ":"+loc.port : "");
            var cometdURL = baseUrl + '/cometd/' + version;
            return cometdURL;
        },
        refreshPage : function(message, currentPageId, namespacePrefix) {
            console.log( 'on channel: ' + JSON.stringify(message.channel) );
            console.log( 'Payload: ' + JSON.stringify(message.data.payload) );
            console.log( 'SObject : ' + JSON.stringify(message.data.sobject ) );
            console.log( 'Replay Id: ' + JSON.stringify(message.data.event.replayId) );
            console.log( 'Full message: ' + JSON.stringify(message) );
            if( message.data.payload ) {
                var objectName = message.data.payload[ namespacePrefix + 'ObjectName__c' ];
                var recordId = message.data.payload[ namespacePrefix + 'RecordId__c' ];
                if( recordId && recordId.length > 14 && recordId.toLowerCase().substring(0,14) == currentPageId.toLowerCase().substring(0,14) ) {
                    window.top.location = '/' + recordId;
                } else {
                    console.log(' It is for different id. no need to refresh. recordId ' + recordId + ' currentPageId ' + currentPageId );
                }
            }
        }
    }
}

