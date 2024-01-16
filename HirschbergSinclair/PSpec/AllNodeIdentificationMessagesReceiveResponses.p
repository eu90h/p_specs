spec AllNodeIdentificationMessagesReceiveResponses observes eNodeIdentification, eNodeIdentificationResponse {
    var pendingBroadcasts: set[int];

    start state NoPendingBroadcasts {
        on eNodeIdentification goto PendingBroadcasts with (req: tNodeIdentificationMessage) {
            pendingBroadcasts += (req.messageID);
        }
    }

    hot state PendingBroadcasts {
        on eNodeIdentificationResponse do (resp: tNodeIdentificationResponse) {
            assert resp.inResponseTo in pendingBroadcasts,
                format ("unexpected broadcast response: {0}, expected one of {1}", resp.messageID, pendingBroadcasts);
            pendingBroadcasts -= (resp.inResponseTo);
            if (sizeof(pendingBroadcasts) == 0) {
                goto NoPendingBroadcasts;
            }
        }

        on eNodeIdentification goto PendingBroadcasts with (req: tNodeIdentificationMessage) {
            pendingBroadcasts += (req.messageID);
        }
    }
}