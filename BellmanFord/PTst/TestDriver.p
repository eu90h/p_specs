machine TestWithSingleClientWithNoFailures {
    start state Init {
        entry {
            var nodes: seq[Node];
            var counter: int;
            var node: Node;
            var outNeighbors: map[Node, set[Node]];
            var weights: map[Node, map[Node, int]];
            var NumNodes: int;
            var ns: set[Node];
            var ro: RoundOrchestrator;
            var rootNode: Node;
            var nodeNames: map[Node, string];
            var distancesToRoot: map[Node, int];
            NumNodes = 10;
            counter = 0;
            while (counter < NumNodes) {
                node = new Node();
                nodes += (counter, node);
                outNeighbors[node] = default(set[Node]);
                weights[node] = default(map[Node, int]);
                distancesToRoot[node] = 2147483647;
                counter = counter+1;
            }
            rootNode = nodes[0];
            
            //topology corresponds to https://en.wikipedia.org/wiki/Breadth-first_search#/media/File:MapGermanyGraph.svg
            nodeNames[nodes[0]] = "Frankfurt";
            outNeighbors[nodes[0]] += (nodes[1]);
            outNeighbors[nodes[0]] += (nodes[2]);
            outNeighbors[nodes[0]] += (nodes[3]);
            weights[nodes[0]][nodes[1]] = 85;
            weights[nodes[0]][nodes[2]] = 217;
            weights[nodes[0]][nodes[3]] = 173;
            distancesToRoot[rootNode] = 0;

            nodeNames[nodes[1]] = "Mannheim";
            outNeighbors[nodes[1]] += (nodes[4]);
            outNeighbors[nodes[1]] += (nodes[0]);
            weights[nodes[1]][nodes[4]] = 80;
            weights[nodes[1]][nodes[0]] = 85;
            distancesToRoot[nodes[1]] = 85;

            nodeNames[nodes[2]] = "Wuerzburg";
            outNeighbors[nodes[2]] += (nodes[0]);
            outNeighbors[nodes[2]] += (nodes[5]);
            outNeighbors[nodes[2]] += (nodes[6]);
            weights[nodes[2]][nodes[5]] = 186;
            weights[nodes[2]][nodes[6]] = 103;
            weights[nodes[2]][nodes[0]] = 217;
            distancesToRoot[nodes[2]] = 217;

            nodeNames[nodes[3]] = "Kassel";
            outNeighbors[nodes[3]] += (nodes[0]);
            outNeighbors[nodes[3]] += (nodes[7]);
            weights[nodes[3]][nodes[7]] = 502;
            weights[nodes[3]][nodes[0]] = 173;
            distancesToRoot[nodes[3]] = 173;

            nodeNames[nodes[4]] = "Karlsruhe";
            outNeighbors[nodes[4]] += (nodes[1]);
            outNeighbors[nodes[4]] += (nodes[8]);
            weights[nodes[4]][nodes[8]] = 250;
            weights[nodes[4]][nodes[1]] = 80;
            distancesToRoot[nodes[4]] = distancesToRoot[nodes[1]] + 80;

            nodeNames[nodes[5]] = "Erfurt";
            outNeighbors[nodes[5]] += (nodes[2]);
            weights[nodes[5]][nodes[2]] = 186;
            distancesToRoot[nodes[5]] = distancesToRoot[nodes[2]] + 186;

            nodeNames[nodes[6]] = "Nuernberg";
            outNeighbors[nodes[6]] += (nodes[2]);
            outNeighbors[nodes[6]] += (nodes[9]);
            outNeighbors[nodes[6]] += (nodes[7]);
            weights[nodes[6]][nodes[2]] = 103;
            weights[nodes[6]][nodes[9]] = 183;
            weights[nodes[6]][nodes[7]] = 167;
            distancesToRoot[nodes[6]] = distancesToRoot[nodes[2]] + 103;

            nodeNames[nodes[7]] = "Muenchen";
            outNeighbors[nodes[7]] += (nodes[8]);
            outNeighbors[nodes[7]] += (nodes[6]);
            outNeighbors[nodes[7]] += (nodes[3]);
            weights[nodes[7]][nodes[8]] = 84;
            weights[nodes[7]][nodes[6]] = 167;
            weights[nodes[7]][nodes[3]] = 502;
            distancesToRoot[nodes[7]] = distancesToRoot[nodes[6]] + 167;

            nodeNames[nodes[8]] = "Augsburg";
            outNeighbors[nodes[8]] += (nodes[4]);
            outNeighbors[nodes[8]] += (nodes[7]);
            weights[nodes[8]][nodes[4]] = 250;
            weights[nodes[8]][nodes[7]] = 84;
            distancesToRoot[nodes[8]] = distancesToRoot[nodes[4]] + 250;

            nodeNames[nodes[9]] = "Stuttgart";
            outNeighbors[nodes[9]] += (nodes[6]);
            weights[nodes[9]][nodes[6]] = 183;
            distancesToRoot[nodes[9]] = distancesToRoot[nodes[6]] + 183;
            announce eInit, (rootNode = rootNode, distancesToRoot=distancesToRoot, nodes=nodes);
            counter = 0;
            ro = new RoundOrchestrator((numNodes=NumNodes,));

            foreach (node in nodes) {
                if (node in outNeighbors) ns = outNeighbors[node];
                else ns = default(set[Node]);
                send node, eTopology, (nodeID = counter, outNeighbors = ns, numNodes = NumNodes, roundOrchestrator=ro, isRoot=rootNode == node, weight=weights[node], nodeName=nodeNames[node], nodeNames=nodeNames, root=rootNode);
                counter = counter + 1;
            }
            foreach (node in nodes) {
                send node, eStart;
            }
        }
    }
}