machine TestWithSingleClientWithNoFailures {
    start state Init {
        entry {
            var nodes: seq[Node];
            var counter: int;
            var node: Node;
            var diameter: int;
            var outNeighbors: map[Node, set[Node]];
            var NumNodes: int;
            var ns: set[Node];
            var ro: RoundOrchestrator;
            NumNodes = 5;
            diameter = 4;
            counter = 0;
            while (counter < NumNodes) {
                node = new Node();
                nodes += (counter, node);
                outNeighbors[node] = default(set[Node]);
                counter = counter+1;
            }
            outNeighbors[nodes[0]] += (nodes[1]);
            outNeighbors[nodes[1]] += (nodes[2]);
            outNeighbors[nodes[2]] += (nodes[4]);
            outNeighbors[nodes[4]] += (nodes[2]);
            outNeighbors[nodes[2]] += (nodes[3]);
            outNeighbors[nodes[3]] += (nodes[0]);
            counter = 0;
            ro = new RoundOrchestrator((numNodes=NumNodes,));
            announce eAllNodes, nodes;
            foreach (node in nodes) {
                if (node in outNeighbors) ns = outNeighbors[node];
                else ns = default(set[Node]);
                send node, eTopology, (nodeID = counter, outNeighbors = ns, diameter = diameter, roundOrchestrator=ro);
                counter = counter + 1;
            }
            foreach (node in nodes) {
                send node, eStart;
            }
        }
    }
}