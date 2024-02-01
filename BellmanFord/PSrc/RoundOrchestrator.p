machine RoundOrchestrator {
    var numNodes: int;
    var nodesFinished: set[Node];
    var n: int;
    start state Init {
        entry (payload: (numNodes: int)){
            numNodes = payload.numNodes;
            goto Working;
        }
    }
    hot state Working {
        entry {
            n = n + 1;
            if (n >= numNodes) goto Finished;
        }
        on eFinishedSendingMessages do (node: Node) {
            nodesFinished += (node);
            if (sizeof(nodesFinished) == numNodes) {
                n = 0;
                print format("advancing round...");
                foreach (node in nodesFinished) {
                    send node, eAdvanceRound;
                }
                nodesFinished = default(set[Node]);
                goto Working;
            }
        }
    }
    state Finished {
        entry {}
    }
}
module RoundOrchestrator = {RoundOrchestrator};