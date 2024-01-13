type tGossip = (src: Server, message: int, msg_id: int);
event eGossip : tGossip;

type tGossipResp = (src: Server, in_response_to: int);
event eGossipResp: tGossipResp;

type tTopologyMsg = (topology: map[Server, set[Server]]);
event eTopologyMsg: tTopologyMsg;

machine Server {
    var nextRespId : int;
    var neighbors : set[Server];
    var messagesSeen : seq[int];
    var numMessagesSeen: int;
    var is_network_unreliable: bool;
    var pendingGossip: set[int];
    var next_gossip_msg_id: int;
    var timers: map[int, Timer];
    var gossipTargets: map[int, Server];
    var retries: map[int, int];

    fun GossipValue(v: int) {
        var s: Server;
        var g: tGossip;
        foreach (s in neighbors) {
            g = (src = this, message = v, msg_id = next_gossip_msg_id);
            Send(s, eGossip, g);
            timers[next_gossip_msg_id] = CreateTimer(this, g);
            gossipTargets[next_gossip_msg_id] = s;
            StartTimer(timers[next_gossip_msg_id]);
            retries[next_gossip_msg_id] = 0;
            next_gossip_msg_id = next_gossip_msg_id + 1;
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
            next_gossip_msg_id = 0;
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
            //for simplicity, assume that sending the broadcast response works always.
            send broadcastReq.src, eBroadcastResp, (src = this, in_response_to = broadcastReq.msg_id);
        }

        on eGossip do (gossip: tGossip) {
            RecordMessage(gossip.message);
            pendingGossip += (gossip.msg_id);
            Send(gossip.src, eGossipResp, (src = this, in_response_to = gossip.msg_id));
        }

        on eReadReq do (readReq: tReadReq) {
            //for simplicity, assume that sending the read response works always.
            send readReq.src, eReadResp, (src = this, messages = messagesSeen);
        }

        on eShutDown do {
            raise halt;
        }

        on eGossipResp do (resp: tGossipResp) {
            assert resp.in_response_to in timers;
            CancelTimer(timers[resp.in_response_to]);
            pendingGossip -= (resp.in_response_to);
        }

        on eTimeOut do (gossip: tGossip) {
            var g: tGossip;
            var s: Server;
            assert gossip.msg_id in timers;
            CancelTimer(timers[gossip.msg_id]);
            g = (src = this, message = gossip.message, msg_id = gossip.msg_id);
            retries[gossip.msg_id] = retries[gossip.msg_id] + 1;
            if (retries[gossip.msg_id] >= 3) {
                // the idea here is that we assume the machine is alright, but that the network is the issue. that means we assume that eventually the machine is reachable.
                send gossipTargets[gossip.msg_id], eGossip, g;
            } else {
                Send(gossipTargets[gossip.msg_id], eGossip, g);
            }
            timers[gossip.msg_id] = CreateTimer(this, g);
            StartTimer(timers[gossip.msg_id]);
        }
    }
}