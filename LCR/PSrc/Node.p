enum tStatus { UNKNOWN, LEADER }

type tNodeIdentificationMessage = (src: machine, messageID: int, nodeID: int);
event eNodeIdentification : tNodeIdentificationMessage;

type tNodeIdentificationResponse = (src: machine, messageID: int, inResponseTo: int);
event eNodeIdentificationResponse : tNodeIdentificationResponse;

type tGetNodeStatus = (src: machine);
event eGetNodeStatus : tGetNodeStatus;

type tGetNodeStatusResponse = (src: machine, status: tStatus);
event eGetNodeStatusResponse : tGetNodeStatusResponse;

type tTopology = (nodeID: int, allNodes: seq[Node]);
event eTopology : tTopology;

event eLeaderFound : int;
event eStart;

machine Node {
    var nodeID: int;
    var networkIsReliable: bool;
    var allNodes: seq[Node];
    var status: tStatus;

    start state Init {
        entry (payload: (networkIsReliable: bool)) {
            networkIsReliable = payload.networkIsReliable;
            status = UNKNOWN;
        }

        on eTopology do (msg: tTopology) {
            nodeID = msg.nodeID;
            allNodes = msg.allNodes;
            goto ProcessingMessages;
        }

    }

    state ProcessingMessages {
        ignore eNodeIdentificationResponse;
        on eStart do {
            var s: Node;
            s = GetNeighbor();
            Send(s, eNodeIdentification, (src = this, messageID = RandomID(), nodeID =  nodeID));
        }

        on eNodeIdentification do (msg: tNodeIdentificationMessage) {
            var s: Node;
            Send(msg.src, eNodeIdentificationResponse, (src = this, messageID = RandomID(), inResponseTo = msg.messageID));
            if (msg.nodeID > nodeID) {
                s = GetNeighbor();
                Send(s, eNodeIdentification, (src = this, messageID = RandomID(), nodeID =  msg.nodeID));
                return;
            }

            if (msg.nodeID == nodeID) {
                announce eLeaderFound, nodeID;
                return;
            }
        }

        on eGetNodeStatus do (msg: tGetNodeStatus) {
            send msg.src, eGetNodeStatusResponse, (src = this, status = status);
        }
    }

    fun GetNeighbor() : Node {
        if (nodeID < sizeof(allNodes) - 1) {
            assert nodeID >= 0;
            return allNodes[nodeID + 1];
        } else {
            assert nodeID == sizeof(allNodes) - 1;
            return allNodes[0];
        }
    }
    fun Send(s: machine, e: event, payload: any) {
        if (networkIsReliable) {
            send s, e, payload;
        } else {
            if ($) UnReliableSend(s, e, payload);
        }
    }
}