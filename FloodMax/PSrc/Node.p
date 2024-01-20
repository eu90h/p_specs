enum tStatus { UNKNOWN, LEADER, NONLEADER }

type tNodeIdentificationMessage = (nodeID: int);
event eNodeIdentification : tNodeIdentificationMessage;

type tTopology = (nodeID: int, outNeighbors: set[Node], diameter: int, roundOrchestrator: RoundOrchestrator);
event eTopology : tTopology;

event eLeaderFound : int;
event eStart;
event eAdvanceRound;
event eFinishedSendingMessages: Node;

machine Node {
    var status: tStatus;
    var nodeID: int;
    var nodeIndex: int;
    var diameter: int;
    var round: int;
    var maxID: int;
    var outNeighbors: set[Node];
    var roundOrchestrator: RoundOrchestrator;

    start state Initializing {
        defer eNodeIdentification;
        entry {
            status = UNKNOWN;
            round = 0;
        }

        on eTopology do (msg: tTopology) {
            nodeID = msg.nodeID;
            maxID = msg.nodeID;
            outNeighbors = msg.outNeighbors;
            diameter = msg.diameter;
            roundOrchestrator = msg.roundOrchestrator;
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
            send outNeighbors[nodeIndex], eNodeIdentification, (nodeID = maxID,);
            nodeIndex = nodeIndex + 1;
            goto BroadcastingID;
        }

        on eNodeIdentification do (msg: tNodeIdentificationMessage) {
            if (maxID < msg.nodeID) {
                maxID = msg.nodeID;
                nodeIndex = 0;
            }
            goto BroadcastingID;
        }
    }

    state FinishedBroadcasting {
        entry {
            send roundOrchestrator, eFinishedSendingMessages, this;
        }

        on eNodeIdentification do (msg: tNodeIdentificationMessage) {
            if (maxID < msg.nodeID) {
                maxID = msg.nodeID;
                nodeIndex = 0;
                goto BroadcastingID;
            }
        }

        on eAdvanceRound do {
            round = round + 1;
            if (round < diameter) {
                goto BroadcastingID;
            }
            if (maxID == nodeID) announce eLeaderFound, maxID;
        }
    }
}
