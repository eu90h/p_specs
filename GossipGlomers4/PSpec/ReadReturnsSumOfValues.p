spec ReadReturnsSumOfValues observes eAdd, eReadResp {
    var vs: seq[int];
    var sumOfDeltas: int;

    start state Init {
        entry {
            sumOfDeltas = 0;
            goto WatchAddsAndReads;
        }
    }

    state WatchAddsAndReads {
        on eAdd do (req: tAdd) {
            sumOfDeltas = sumOfDeltas + req.delta;
            vs += (sizeof(vs), req.delta);
        }

        on eReadResp do (resp : tReadResp) {
            assert sumOfDeltas == resp.value, format("expected {0}, got {1}", sumOfDeltas, resp.value);
        }
    }
}