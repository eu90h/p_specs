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

    fun GossipValue(v: int) {
        var s: Server;
        foreach (s in neighbors) {
            send s, eGossip, (src = this, message = v);
        }
    }

    fun RecordMessage(v: int) {
        messagesSeen += (numMessagesSeen, v);
        numMessagesSeen = numMessagesSeen + 1;
    }

    start state Serve {
        on eTopologyMsg do (topologyMsg : tTopologyMsg) {
            neighbors = topologyMsg.topology[this];
        }

        on eBroadcastReq do (broadcastReq: tBroadcastReq) {
            RecordMessage(broadcastReq.message);
            GossipValue(broadcastReq.message);
            send broadcastReq.src, eBroadcastResp, (src = this, in_response_to = broadcastReq.msg_id);
        }

        on eGossip do (gossip: tGossip) {
            RecordMessage(gossip.message);
            send gossip.src, eGossipResp, (src = this,);
        }

        on eReadReq do (readReq: tReadReq) {
            send readReq.src, eReadResp, (src = this, messages = messagesSeen);
        }

        on eShutDown do {
            raise halt;
        }

        on eGossipResp do {}
    }
}