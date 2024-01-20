machine RoundOrchestrator {
    var numNodes: int;
    var nodesFinished: set[Node];
    start state Working {
        entry (payload: (numNodes: int)){
            numNodes = payload.numNodes;
        }
        on eFinishedSendingMessages do (node: Node) {
            nodesFinished += (node);
            if (sizeof(nodesFinished) == numNodes) {
                foreach (node in nodesFinished) {
                    send node, eAdvanceRound;
                }
                nodesFinished = default(set[Node]);
            }
        }
    }
}
module RoundOrchestrator = {RoundOrchestrator};