type tGossip = (src: Server, counters: map[Server, int], msg_id: int, tag: int);
event eGossip : tGossip;

type tGossipResp = (src: Server, in_response_to: int, tag:int);
event eGossipResp: tGossipResp;

type tTopologyMsg = (topology: map[Server, set[Server]], allServers: set[Server]);
event eTopologyMsg: tTopologyMsg;

type tPendingGossip = (dest: Server, msg: tGossip);
type tCountersReq = (src: machine, msg_id: int, read_req_id: int);
event eCountersReq : tCountersReq;

type tCountersResp = (src: Server, counters: map[Server, int], in_response_to: int, read_req_id: int);
event eCountersResp: tCountersResp;

type tSecondaryCounterRequest = (og: tCountersReq, req: tCountersReq);

machine Server {
    var neighbors: set[Server];
    var counters: map[Server, int];
    var isNetworkUnreliable: bool;
    var pendingReadRequests: set[tReadReq];
    var pendingCounterRequests: set[tCountersReq];
    var counterResponses: map[int, set[tCountersResp]];
    var secondaryCounterResponses: map[int, set[tCountersResp]];
    var seenCounterRequestIDs: set[int];
    var pendingSecondaryCounterRequests: set[tSecondaryCounterRequest];

    start state Init {
        entry (payload : (isNetworkUnreliable: bool)) {
            counters[this] = 0;
            isNetworkUnreliable = payload.isNetworkUnreliable;
        }

        on eTopologyMsg do (topologyMsg : tTopologyMsg) {
            var s: Server;
            neighbors = topologyMsg.topology[this];
            foreach (s in topologyMsg.allServers) {
                if (s in counters == false) counters[s] = 0;
            }
            goto Serve;
        }
    }

    state Serve {
        entry {
            assert sizeof(neighbors) > 0;
        }

        on eAdd do (addMsg: tAdd) {            
            counters[this] = counters[this] + addMsg.delta;
            send addMsg.src, eAddResp, (src = this, in_response_to = addMsg.msg_id);
        }

        on eReadReq do (readReq: tReadReq) {
            var s: Server;
            var c: tCountersReq;
            pendingReadRequests += (readReq);
            // ask all neighbors for their counters
            foreach (s in neighbors) {
                c = (src = this, msg_id = RandomID(), read_req_id = readReq.msg_id);
                pendingCounterRequests += (c);
                seenCounterRequestIDs += (c.read_req_id);
                send s, eCountersReq, c;
            }
        }

        on eCountersResp do (countersResp: tCountersResp) {
            var associatedPendingReadRequest: tReadReq;
            var associatedCountersRequest: tCountersReq;
            var associatedSecondaryCountersRequest: tSecondaryCounterRequest;
            var r: tReadReq;
            var c: tCountersReq;
            var cr: tCountersResp;
            var sc: tSecondaryCounterRequest;
            var foundReadRequest: bool;
            var foundCountersRequest: bool;
            var foundSecondaryCountersRequest: bool;
            foundCountersRequest = false;
            foundReadRequest = false;
            foundSecondaryCountersRequest = false;
            foreach (r in pendingReadRequests) {
                if (r.msg_id == countersResp.read_req_id) {
                    associatedPendingReadRequest = r;
                    foundReadRequest = true;
                }
            }
            if (foundReadRequest) {
                if (associatedPendingReadRequest.msg_id in counterResponses == false) {
                    counterResponses[associatedPendingReadRequest.msg_id] = default(set[tCountersResp]);
                }
                foreach (c in pendingCounterRequests) {
                    if (c.msg_id == countersResp.in_response_to) {
                        associatedCountersRequest = c;
                        foundCountersRequest = true;
                    }
                }
                assert foundCountersRequest;
                counterResponses[associatedPendingReadRequest.msg_id] += (countersResp);
                if (sizeof(counterResponses[associatedPendingReadRequest.msg_id]) != sizeof(neighbors)) {
                    return;
                }
                //all counterResponses received -- time to send the response
                foreach (cr in counterResponses[associatedPendingReadRequest.msg_id]) {
                    Merge(cr.counters);
                }
                send associatedPendingReadRequest.src, eReadResp, (src = this, value = Value(), in_response_to = associatedPendingReadRequest.msg_id);
            } else {
                foreach (c in pendingCounterRequests) {
                    if (c.msg_id == countersResp.in_response_to) {
                        associatedCountersRequest = c;
                        foundCountersRequest = true;
                    }
                }
                assert foundCountersRequest == false;
                foreach (sc in pendingSecondaryCounterRequests) {
                    if (sc.req.msg_id == countersResp.in_response_to) {
                        associatedSecondaryCountersRequest = sc;
                        foundSecondaryCountersRequest = true;
                    }
                }
                assert foundSecondaryCountersRequest;
                if (associatedSecondaryCountersRequest.og.msg_id in secondaryCounterResponses == false) {
                    secondaryCounterResponses[associatedSecondaryCountersRequest.og.msg_id] = default(set[tCountersResp]);
                }
                secondaryCounterResponses[associatedSecondaryCountersRequest.og.msg_id] += (countersResp);
                if (sizeof(secondaryCounterResponses[associatedSecondaryCountersRequest.og.msg_id]) != sizeof(neighbors) - 1) {
                    return;
                }
                //all counterResponses received -- time to send the response
                foreach (cr in secondaryCounterResponses[associatedSecondaryCountersRequest.og.msg_id]) {
                    Merge(cr.counters);
                }
                send associatedSecondaryCountersRequest.og.src, eCountersResp, (src = this, counters = counters, in_response_to = associatedSecondaryCountersRequest.og.msg_id, read_req_id = associatedSecondaryCountersRequest.og.read_req_id);
            }
        }

        on eCountersReq do (countersReq: tCountersReq) {
            var s: Server;
            var cr: tCountersReq;
            var sentCounterRequest: bool;
            sentCounterRequest = false;
            if (countersReq.read_req_id in seenCounterRequestIDs) {
                send countersReq.src, eCountersResp, (src = this, counters = counters, in_response_to = countersReq.msg_id, read_req_id = countersReq.read_req_id);
                return;
            }
            seenCounterRequestIDs += (countersReq.read_req_id);
            //send a counters request to all of this node's neighbors.
            pendingCounterRequests += (countersReq);
            foreach (s in neighbors) {
                if (countersReq.src != s) {
                    sentCounterRequest = true;
                    cr = (src = this, msg_id = RandomID(), read_req_id = countersReq.read_req_id);
                    pendingSecondaryCounterRequests += ((og = countersReq, req = cr));
                    send s, eCountersReq, cr;
                }
            }
            if (!sentCounterRequest) {
                send countersReq.src, eCountersResp, (src = this, counters = counters, in_response_to = countersReq.msg_id, read_req_id = countersReq.read_req_id);
            }
        }
    }

    fun Value() : int{
        var s: Server;
        var v: int;
        v = 0;
        foreach (s in keys(counters)) {
            v = v + counters[s];
        }
        return v;
    }

    fun Merge(other: map[Server, int]) {
        var s: Server;
        var allKeys: set[Server];
        foreach (s in keys(other)) {
            if (s in allKeys == false) allKeys += (s);
        }
        foreach (s in keys(counters)) {
            if (s in allKeys == false) allKeys += (s);
        }
        foreach (s in allKeys) {
            if (s in counters && s in other) {
                if (counters[s] < other[s]) {
                    counters[s] = other[s];
                }
            } else {
                if (s in other) {
                    counters[s] = other[s];
                }
            }
        }
    }

    fun Send(target: machine, message: event, payload: any) {
        if(isNetworkUnreliable) UnReliableSend(target, message, payload);
        else send target, message, payload;
    }
}