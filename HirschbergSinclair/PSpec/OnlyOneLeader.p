event eAllNodes : seq[Node];

spec OnlyOneLeader observes eLeaderFound, eAllNodes {
    var allNodes: seq[Node];
    
    start state Init {
        on eAllNodes do (n: seq[Node]) {
            allNodes = n;
            goto WaitingForElectionToFinish;
        }
    }

    hot state WaitingForElectionToFinish {
        on eLeaderFound goto ElectionFinished with (leaderID: int) {
            assert leaderID == sizeof(allNodes) - 1, format("got {0}, expected {1}", leaderID, sizeof(allNodes) - 1);
        }
    }

    state ElectionFinished {
        entry {}
    }
}