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
            var rootNode: Node;
            NumNodes = 10;
            diameter = 5;
            counter = 0;
            while (counter < NumNodes) {
                node = new Node();
                nodes += (counter, node);
                outNeighbors[node] = default(set[Node]);
                counter = counter+1;
            }
            //topology corresponds to https://en.wikipedia.org/wiki/Breadth-first_search#/media/File:MapGermanyGraph.svg
            outNeighbors[nodes[0]] += (nodes[1]);
            outNeighbors[nodes[0]] += (nodes[2]);
            outNeighbors[nodes[0]] += (nodes[3]);

            outNeighbors[nodes[1]] += (nodes[4]);

            outNeighbors[nodes[2]] += (nodes[5]);
            outNeighbors[nodes[2]] += (nodes[6]);

            outNeighbors[nodes[3]] += (nodes[7]);

            outNeighbors[nodes[4]] += (nodes[8]);

            outNeighbors[nodes[6]] += (nodes[9]);
            outNeighbors[nodes[6]] += (nodes[7]);

            outNeighbors[nodes[8]] += (nodes[7]);
            counter = 0;
            ro = new RoundOrchestrator((numNodes=NumNodes,));
            announce eAllNodes, nodes;
            rootNode = nodes[0];
            foreach (node in nodes) {
                if (node in outNeighbors) ns = outNeighbors[node];
                else ns = default(set[Node]);
                send node, eTopology, (nodeID = counter, outNeighbors = ns, diameter = diameter, roundOrchestrator=ro, isRoot=rootNode == node);
                counter = counter + 1;
            }
            foreach (node in nodes) {
                send node, eStart;
            }
        }
    }
}