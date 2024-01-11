type tGossip = (src: Server, message: int);
event eGossip : tGossip;

type tGossipResp = (src: Server);
event eGossipResp: tGossipResp;

type tTopologyMsg = (topology: map[Server, set[Server]]);
event eTopologyMsg: tTopologyMsg;

machine Server {
    var nextRespId : int;
    var neighbors : set[Server];
    var messagesSeen : seq[int];
    var numMessagesSeen: int;

    start state Serve {
        on eTopologyMsg do (topologyMsg : tTopologyMsg) {
            neighbors = topologyMsg.topology[this];
            assert sizeof(neighbors) > 0;
        }

        on eBroadcastReq do (broadcastReq: tBroadcastReq) {
            var response: tBroadcastResp;
            var gossip: tGossip;
            var s: Server;

            messagesSeen += (numMessagesSeen, broadcastReq.message);
            numMessagesSeen = numMessagesSeen + 1;
            response = (src = this,);
            send broadcastReq.src, eBroadcastResp, response;           
            gossip = (src = this, message = broadcastReq.message);

            foreach (s in neighbors) {
                send s, eGossip, gossip;
            }
        }

        on eGossip do (gossip: tGossip) {
            var response: tGossipResp;

            messagesSeen += (numMessagesSeen, gossip.message);
            numMessagesSeen = numMessagesSeen + 1;
            response = (src = this,);
            send gossip.src, eGossipResp, response;
        }

        on eGossipResp do (gossipResp: tGossipResp) {}

        on eReadReq do (readReq: tReadReq) {
            var response: tReadResp;

            assert sizeof(messagesSeen) > 0;
            response = (src = this, messages = messagesSeen);
            send readReq.src, eReadResp, response;
        }
    }
}