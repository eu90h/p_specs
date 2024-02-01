type tInit = (rootNode:Node, distancesToRoot:map[Node, int], nodes: seq[Node]);
event eAllNodes : seq[Node];
event eInit: tInit;

spec EnsureDistancesAreMinimized observes eAllDone, eInit {
    var allNodes: seq[Node];
    var nodesFinished: int;
    var childMap: map[Node, set[Node]];
    var rootNode: Node;
    var parentMap: map[Node, Node];
    var round: int;
    var distances: map[Node, int];
    var receivedDistances: map[Node, int];

    start state Init {
        on eInit do (msg: tInit) {
            allNodes = msg.nodes;
            rootNode = msg.rootNode;
            distances = msg.distancesToRoot;
            goto WaitingForElectionToFinish;
        }
    }

    hot state WaitingForElectionToFinish {
        on eAllDone do (msg: tFinished) {
            nodesFinished = nodesFinished + 1;
            receivedDistances[msg.node] = msg.distanceToRoot;
            if (nodesFinished >= sizeof(allNodes)) {
                goto ElectionFinished;
            }
        }
    }

    state ElectionFinished {
        entry {
            var node: Node;
            foreach (node in allNodes) {
                if (node != rootNode) assert receivedDistances[node] == distances[node], format("got {0} expected {1}", receivedDistances[node], distances[node]);
                else assert receivedDistances[node] == 0;
            }
        }
    }
}