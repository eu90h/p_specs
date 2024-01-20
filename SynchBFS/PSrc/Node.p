enum tStatus { UNKNOWN, LEADER, NONLEADER }

type tNodeIdentificationMessage = (node: Node, dest: Node);
event eNodeIdentification : tNodeIdentificationMessage;

type tTopology = (nodeID: int, outNeighbors: set[Node], diameter: int, roundOrchestrator: RoundOrchestrator, isRoot: bool);
event eTopology : tTopology;

type tFinished = (node: Node, parent: Node);
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
    var diameter: int;
    var round: int;
    var parent: Node;
    var outNeighbors: set[Node];
    var roundOrchestrator: RoundOrchestrator;
    var choseParent: bool;

    start state Initializing {
        defer eNodeIdentification;
        entry {
            status = UNKNOWN;
            round = 0;
        }

        on eTopology do (msg: tTopology) {
            outNeighbors = msg.outNeighbors;
            diameter = msg.diameter;
            roundOrchestrator = msg.roundOrchestrator;
            parent = this;
            choseParent = msg.isRoot;
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
            if (!choseParent || (choseParent && outNeighbors[nodeIndex] != parent)) send outNeighbors[nodeIndex], eNodeIdentification, (node = this, dest = outNeighbors[nodeIndex]);
            nodeIndex = nodeIndex + 1;
            goto BroadcastingID;
        }

        on eNodeIdentification do (msg: tNodeIdentificationMessage) {
            if (!choseParent) {
                parent = msg.node;
                choseParent = true;
                print format("{0} chose {1} as parent", this, parent);
                announce eParentFound, (node = this, parent = parent);
            }
            goto BroadcastingID;
        }
    }

    state FinishedBroadcasting {
        ignore eNodeIdentification;

        entry {
            send roundOrchestrator, eFinishedSendingMessages, this;
        }

        on eAdvanceRound do {
            announce eAllDone, (node = this, parent = parent);
        }
    }
}
module Node = { Node };