enum tStatus { UNKNOWN, LEADER }

enum tDirection { OUT, IN }

type tNodeIdentificationMessage = (src: machine, messageID: int, nodeID: int, direction: tDirection, hopCount: int);
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
    var phase: int;
    var leftMessage: tNodeIdentificationMessage;
    var rightMessage: tNodeIdentificationMessage;
    var H: int;
    var elected: int;
    var N: int;

    start state Init {
        entry (payload: (networkIsReliable: bool)) {
            networkIsReliable = payload.networkIsReliable;
            status = UNKNOWN;
            H = 1;
            N = 1;
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
            var leftNeighbor: Node;
            var rightNeighbor: Node;
            leftNeighbor = GetLeftNeighbor();
            rightNeighbor = GetRightNeighbor();
            Send(leftNeighbor, eNodeIdentification, (src = this, messageID = RandomID(), nodeID =  nodeID, direction = OUT, hopCount = H));
            Send(rightNeighbor, eNodeIdentification, (src = this, messageID = RandomID(), nodeID =  nodeID, direction = OUT, hopCount = H));
        }

        on eNodeIdentification do (msg: tNodeIdentificationMessage) {
            var s: Node;
            var leftNeighbor: Node;
            var rightNeighbor: Node;
            print format("node {0} elections: {1}", nodeID, elected);
            leftNeighbor = GetLeftNeighbor();
            rightNeighbor = GetRightNeighbor();
            if (msg.src == leftNeighbor) {
                leftMessage = msg;
            }
            if (msg.src == rightNeighbor) {
                rightMessage = msg;
            }
            Send(msg.src, eNodeIdentificationResponse, (src = this, messageID = RandomID(), inResponseTo = msg.messageID));
           if (leftMessage.nodeID == rightMessage.nodeID && leftMessage.nodeID == nodeID && leftMessage.direction == rightMessage.direction && leftMessage.direction == IN && leftMessage.hopCount == rightMessage.hopCount && leftMessage.hopCount == 1) {
                phase = phase + 1;
                H = 2 * H;
                Send(rightNeighbor, eNodeIdentification, (src = this, messageID = RandomID(), nodeID = nodeID, direction = OUT, hopCount = H));
                Send(leftNeighbor, eNodeIdentification, (src = this, messageID = RandomID(), nodeID = nodeID, direction = OUT, hopCount = H));
            }
             if (msg.src == leftNeighbor && msg.direction == OUT) {
                    if (msg.nodeID > nodeID && msg.hopCount > 1) {
                        Send(rightNeighbor, eNodeIdentification, (src = this, messageID = RandomID(), nodeID =  msg.nodeID, direction = OUT, hopCount = msg.hopCount - 1));
                        return;
                    }
                    if (msg.nodeID > nodeID && msg.hopCount <= 1) {
                        assert msg.hopCount == 1;
                        Send(leftNeighbor, eNodeIdentification, (src = this, messageID = RandomID(), nodeID = msg.nodeID, direction = IN, hopCount = 1));
                        return;
                    }

                    if (msg.nodeID == nodeID) {
                        elected = elected + 1;
                        if (elected >= N) goto ElectionFinished;
                    }
            }
            if (msg.src == rightNeighbor && msg.direction == OUT) {
                if (msg.nodeID > nodeID && msg.hopCount > 1) {
                        Send(leftNeighbor, eNodeIdentification, (src = this, messageID = RandomID(), nodeID =  msg.nodeID, direction = OUT, hopCount = msg.hopCount - 1));
                        return;
                    }
                    if (msg.nodeID > nodeID && msg.hopCount <= 1) {
                        assert msg.hopCount == 1;
                        Send(rightNeighbor, eNodeIdentification, (src = this, messageID = RandomID(), nodeID = msg.nodeID, direction = IN, hopCount = 1));
                        return;
                    }

                    if (msg.nodeID == nodeID) {
                        elected = elected + 1;
                        if (elected >= N) goto ElectionFinished;
                    }
            }
            if (msg.src == leftNeighbor && msg.direction == IN && msg.hopCount == 1 && msg.nodeID != nodeID) {
                Send(rightNeighbor, eNodeIdentification, (src = this, messageID = RandomID(), nodeID = msg.nodeID, direction = IN, hopCount = 1));
                return;
            }
            if (msg.src == rightNeighbor && msg.direction == IN && msg.hopCount == 1 && msg.nodeID != nodeID) {
                Send(leftNeighbor, eNodeIdentification, (src = this, messageID = RandomID(), nodeID = msg.nodeID, direction = IN, hopCount = 1));
                return;
            }
        }

        on eGetNodeStatus do (msg: tGetNodeStatus) {
            send msg.src, eGetNodeStatusResponse, (src = this, status = status);
        }
    }

    state ElectionFinished {
        ignore eNodeIdentificationResponse;
        entry {
            announce eLeaderFound, nodeID;
        }

        on eNodeIdentification do (msg: tNodeIdentificationMessage) {
            assert msg.nodeID <= nodeID; 
            send msg.src, eNodeIdentificationResponse, (src = this, messageID = RandomID(), inResponseTo = msg.messageID);
        }
    }

    fun GetRightNeighbor() : Node {
        if (nodeID < sizeof(allNodes) - 1) {
            assert nodeID >= 0;
            return allNodes[nodeID + 1];
        } else {
            assert nodeID == sizeof(allNodes) - 1;
            return allNodes[0];
        }
    }
    
    fun GetLeftNeighbor() : Node {
        if (nodeID > 0) {
            assert nodeID < sizeof(allNodes);
            return allNodes[nodeID - 1];
        } else {
            assert nodeID == 0;
            return allNodes[sizeof(allNodes) - 1];
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
