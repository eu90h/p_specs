enum tStatus { UNKNOWN, LEADER, NONLEADER }

type tNodeIdentificationMessage = (src: Node, dest: Node, dist: int);
event eNodeIdentification : tNodeIdentificationMessage;

type tTopology = (nodeID: int, outNeighbors: set[Node], numNodes: int, roundOrchestrator: RoundOrchestrator, isRoot: bool, weight: map[Node, int], nodeName: string, nodeNames: map[Node, string], root: Node);
event eTopology : tTopology;

type tFinished = (node: Node, parent: Node, distanceToRoot: int);
event eLeaderFound : int;
event eStart;
event eAdvanceRound;
event eFinishedSendingMessages: Node;
event eAllDone: tFinished;
event eParentFound: tFinished;

machine Node {
    var status: tStatus;
    var nodeID: int;
    var nodeIndex: int;
    var numNodes: int;
    var round: int;
    var parent: Node;
    var outNeighbors: set[Node];
    var roundOrchestrator: RoundOrchestrator;
    var choseParent: bool;
    var dist: int;
    var weight: map[Node, int];
    var nodeName: string;
    var nodeNames: map[Node, string];
    var rootNode: Node;

    start state Initializing {
        defer eNodeIdentification;
        entry {
            status = UNKNOWN;
            round = 0;
            dist = 2147483647;
        }

        on eTopology do (msg: tTopology) {
            outNeighbors = msg.outNeighbors;
            numNodes = msg.numNodes;
            roundOrchestrator = msg.roundOrchestrator;
            parent = this;
            choseParent = msg.isRoot;
            weight = msg.weight;
            if (msg.isRoot) dist = 0;
            nodeName = msg.nodeName;
            nodeNames = msg.nodeNames;
            rootNode = msg.root;
        }

        on eStart do {
            goto BroadcastingID;
        }
    }

    hot state BroadcastingID {
        entry {
            if (nodeIndex >= sizeof(outNeighbors)) {
                nodeIndex = 0;
                goto FinishedBroadcasting;
            }
            if (dist != 2147483647) send outNeighbors[nodeIndex], eNodeIdentification, (src = this, dest = outNeighbors[nodeIndex], dist = dist);
            nodeIndex = nodeIndex + 1;
            goto BroadcastingID;
        }

        on eNodeIdentification do (msg: tNodeIdentificationMessage) {
            assert msg.src in weight, format("{0} not in {1}", msg.src, weight);
            if (dist > msg.dist + weight[msg.src]) {
                dist = msg.dist + weight[msg.src];
                parent = msg.src;
                print format("[{2}] {3} -> {0} dist = {1}", nodeName, dist, round, nodeNames[rootNode]);
                nodeIndex = 0;
                goto BroadcastingID;
            }
        }
    }

    state FinishedBroadcasting {
        entry {
            send roundOrchestrator, eFinishedSendingMessages, this;
        }
     
        on eNodeIdentification do (msg: tNodeIdentificationMessage) {
            assert msg.src in weight, format("{0} not in {1}", msg.src, weight);
            if (dist > msg.dist + weight[msg.src]) {
                dist = msg.dist + weight[msg.src];
                parent = msg.src;
                print format("[{2}] {3} -> {0} dist = {1}", nodeName, dist, round, nodeNames[rootNode]);
                nodeIndex = 0;
                goto BroadcastingID;
            }
        }
        
        on eAdvanceRound do {
            round = round + 1;
            if (round < numNodes - 1) goto BroadcastingID;
            else announce eAllDone, (node = this, parent = parent, distanceToRoot = dist);
        }
    }
}
module Node = { Node };