event eAllNodes : seq[Node];

// This essentially checks to see that lemma 3.1.2 of https://www.cs.yale.edu/homes/aspnes/classes/465/notes.pdf holds.
// Namely, if u.parent isn't null, then u.parent.parent isn't null and following parent pointers gives a path from u to the root.
spec CheckBFSTreeInvariants observes eAllDone, eAllNodes,eNodeIdentification {
    var allNodes: seq[Node];
    var nodesFinished: int;
    var childMap: map[Node, set[Node]];
    var rootNode: Node;
    var parentMap: map[Node, Node];
    start state Init {
        on eAllNodes do (n: seq[Node]) {
            allNodes = n;
            goto WaitingForElectionToFinish;
        }
    }

    hot state WaitingForElectionToFinish {
        on eNodeIdentification do (msg: tNodeIdentificationMessage) {
            var p: Node;
            if (msg.node in parentMap) {
                p = parentMap[msg.node];
                assert p in parentMap;
            }
        }

        on eParentFound do (msg: tFinished) {
            if (msg.parent in childMap == false) {
                childMap[msg.parent] = default(set[Node]);
            }
            assert msg.node in childMap[msg.parent] == false;
            parentMap[msg.node] = msg.parent;
            if (msg.parent != msg.node) childMap[msg.parent] += (msg.node); 
            else rootNode = msg.node;
        }

        on eAllDone do (msg: tFinished) {
            if (msg.parent in childMap == false) {
                childMap[msg.parent] = default(set[Node]);
            }
            assert msg.node in childMap[msg.parent] == false;
            parentMap[msg.node] = msg.parent;
            if (msg.parent != msg.node) childMap[msg.parent] += (msg.node); 
            else rootNode = msg.node;
            nodesFinished = nodesFinished + 1;
            if (nodesFinished >= sizeof(allNodes)) {
                goto ElectionFinished;
            }
        }
    }

    state ElectionFinished {
        entry {
            var node: Node;
            var p: Node;
            var q: Node;
            foreach (node in allNodes) {
                q = node;
                while (true) {
                    p = parentMap[q];
                    if (q == p) break;
                    else {
                        assert q in childMap[p];
                        q = p;
                    }
                }
            }

        }
    }
}