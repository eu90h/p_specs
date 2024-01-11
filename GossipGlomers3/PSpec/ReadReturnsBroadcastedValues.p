spec ReadReturnsBroadcastedValues observes eBroadcastReq, eReadReq, eReadResp {
    var broadcastedValues: seq[int];
    var numValuesBroadcasted: int;
    var numReadReqs: int;
    var numReadResps: int;

    start state Init {
        entry {
            numValuesBroadcasted = 0;
            goto BroadcastAndRead;
        }
    }

    state BroadcastAndRead {
        on eBroadcastReq do (req: tBroadcastReq) {
            broadcastedValues += (numValuesBroadcasted, req.message);
            numValuesBroadcasted = numValuesBroadcasted + 1;
        }

        on eReadReq do {
            numReadReqs = numReadReqs + 1;
        }

        on eReadResp do (resp : tReadResp) {
            var x : int;
            numReadResps = numReadResps + 1;
            if (numReadReqs == numReadResps) {
                foreach (x in resp.messages) {
                    assert x in broadcastedValues, format("expected {0}, got {1}", broadcastedValues, resp.messages);
                }
            }
        }
    }
}