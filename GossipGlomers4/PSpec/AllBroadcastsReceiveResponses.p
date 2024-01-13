spec AllBroadcastsReceiveResponses observes eAdd, eAddResp {
    var pendingBroadcasts: set[int];

    start state NoPendingBroadcasts {
        on eAdd goto PendingBroadcasts with (req: tAdd) {
            pendingBroadcasts += (req.msg_id);
        }
    }

    hot state PendingBroadcasts {
        on eAddResp do (resp: tAddResp) {
            assert resp.in_response_to in pendingBroadcasts,
                format ("unexpected broadcast response: {0}, expected one of {1}", resp.in_response_to, pendingBroadcasts);
            pendingBroadcasts -= (resp.in_response_to);
            if (sizeof(pendingBroadcasts) == 0) {
                goto NoPendingBroadcasts;
            }
        }

        on eAdd goto PendingBroadcasts with (req: tAdd) {
            pendingBroadcasts += (req.msg_id);
        }
    }
}