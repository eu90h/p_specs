machine TestWithSingleClientWithNoFailures {
    start state Init {
        entry {
            var nodes: seq[Node];
            var counter: int;
            var node: Node;
            counter = 0;
            while (counter < 3) {
                node = new Node((networkIsReliable = true,));
                nodes += (counter, node);
                counter = counter+1;
            }
            announce eAllNodes, nodes;
            counter = 0;
            foreach (node in nodes) {
                send node, eTopology, (nodeID = counter, allNodes = nodes);
                counter = counter+1;
            }
            foreach (node in nodes) {
                send node, eStart;
            }
        }
    }
}