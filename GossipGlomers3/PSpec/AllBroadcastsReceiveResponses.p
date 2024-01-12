spec AllBroadcastsReceiveResponses observes eBroadcastReq, eBroadcastResp {
    var pendingBroadcasts: set[int];

    start state NoPendingBroadcasts {
        on eBroadcastReq goto PendingBroadcasts with (req: tBroadcastReq) {
            pendingBroadcasts += (req.msg_id);
        }
    }

    hot state PendingBroadcasts {
        on eBroadcastResp do (resp: tBroadcastResp) {
            assert resp.in_response_to in pendingBroadcasts,
                format ("unexpected broadcast response: {0}, expected one of {1}", resp.in_response_to, pendingBroadcasts);
            pendingBroadcasts -= (resp.in_response_to);
            if (sizeof(pendingBroadcasts) == 0) {
                goto NoPendingBroadcasts;
            }
        }

        on eBroadcastReq goto PendingBroadcasts with (req: tBroadcastReq) {
            pendingBroadcasts += (req.msg_id);
        }
    }
}