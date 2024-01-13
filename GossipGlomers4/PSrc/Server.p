type tGossip = (src: Server, message: int, msg_id: int);
event eGossip : tGossip;

type tGossipResp = (src: Server, in_response_to: int);
event eGossipResp: tGossipResp;

type tTopologyMsg = (topology: map[Server, set[Server]]);
event eTopologyMsg: tTopologyMsg;

machine Server {
    var deltasSeen: seq[int];
    var sumOfDeltas: int;
    var is_network_unreliable: bool;
    var neighbors: set[Server];
    var gossipMessagesSeen: set[int];

    fun GossipValue(g: tGossip) {
        var s: Server;
        foreach (s in neighbors) {
            Send(s, eGossip, g);
        }
    }

    fun RecordValue(gossip: tGossip) {
        gossipMessagesSeen += (gossip.msg_id);
        deltasSeen += (sizeof(deltasSeen), gossip.message);
        sumOfDeltas = sumOfDeltas + gossip.message;
    }
    fun Rebroadcast(gossip: tGossip) {
        var s: Server;
        foreach (s in neighbors) {
            if (s != gossip.src) {
                Send(s, eGossip, (src = this, message = gossip.message, msg_id = gossip.msg_id));
            }
        }
    }

    fun Send(target: machine, message: event, payload: any) {
        if(is_network_unreliable) UnReliableSend(target, message, payload);
        else send target, message, payload;
    }

    start state Init {
        entry (payload : (is_network_unreliable: bool)) {
            is_network_unreliable = payload.is_network_unreliable;
            sumOfDeltas = 0;
            goto Serve;
        }
    }

    state Serve {
        on eTopologyMsg do (topologyMsg : tTopologyMsg) {
            neighbors = topologyMsg.topology[this];
        }

        on eAdd do (addMsg: tAdd) {
            var gossip: tGossip;
            gossip = (src = this, message = addMsg.delta, msg_id = RandomID());
            RecordValue(gossip);
            GossipValue(gossip);
            //for simplicity, assume that sending the broadcast response works always.
            send addMsg.src, eAddResp, (src = this, in_response_to = addMsg.msg_id);
        }

        on eGossip do (gossip: tGossip) {
            if (gossip.msg_id in gossipMessagesSeen) {
                send gossip.src, eGossipResp, (src = this, in_response_to = gossip.msg_id);
                return;
            }
            RecordValue(gossip);
            Rebroadcast(gossip);
            Send(gossip.src, eGossipResp, (src = this, in_response_to = gossip.msg_id));
        }

        on eReadReq do (readReq: tReadReq) {
            //for simplicity, assume that sending the read response works always.
            send readReq.src, eReadResp, (src = this, value = sumOfDeltas, in_response_to = readReq.msg_id);
        }

        on eGossipResp do (resp: tGossipResp) {}
    }
}