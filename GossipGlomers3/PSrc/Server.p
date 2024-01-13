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
    var is_network_unreliable: bool;

    fun GossipValue(v: int) {
        var s: Server;
        foreach (s in neighbors) {
            Send(s, eGossip, (src = this, message = v));
        }
    }

    fun Send(target: machine, message: event, payload: any) {
        if(is_network_unreliable) UnReliableSend(target, message, payload);
        else send target, message, payload;
    }

    fun RecordMessage(v: int) {
        messagesSeen += (numMessagesSeen, v);
        numMessagesSeen = numMessagesSeen + 1;
    }

    start state Init {
        entry (payload : (is_network_unreliable: bool)) {
            is_network_unreliable = payload.is_network_unreliable;
            goto Serve;
        }
    }

    state Serve {
        on eTopologyMsg do (topologyMsg : tTopologyMsg) {
            neighbors = topologyMsg.topology[this];
        }

        on eBroadcastReq do (broadcastReq: tBroadcastReq) {
            RecordMessage(broadcastReq.message);
            GossipValue(broadcastReq.message);
            Send(broadcastReq.src, eBroadcastResp, (src = this, in_response_to = broadcastReq.msg_id));
        }

        on eGossip do (gossip: tGossip) {
            RecordMessage(gossip.message);
            Send(gossip.src, eGossipResp, (src = this,));
        }

        on eReadReq do (readReq: tReadReq) {
            Send(readReq.src, eReadResp, (src = this, messages = messagesSeen));
        }

        on eShutDown do {
            raise halt;
        }

        on eGossipResp do {}
    }
}