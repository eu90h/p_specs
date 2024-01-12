spec ReadReturnsBroadcastedValues observes eBroadcastReq, eReadResp {
    var broadcastedValues: seq[int];

    start state Init {
        entry {
            goto BroadcastAndRead;
        }
    }

    state BroadcastAndRead {
        on eBroadcastReq do (req: tBroadcastReq) {
            broadcastedValues += (sizeof(broadcastedValues), req.message);
        }

        on eReadResp do (resp : tReadResp) {
            var x : int;
            foreach (x in resp.messages) {
                assert x in broadcastedValues, format("expected {0}, got {1}", broadcastedValues, resp.messages);
            }
        }
    }
}