type tBroadcastReq = (src: Client, message: int, msg_id: int);
event eBroadcastReq : tBroadcastReq;

type tBroadcastResp = (src: Server, in_response_to: int);
event eBroadcastResp: tBroadcastResp;

type tReadReq = (src: Client);
event eReadReq : tReadReq;

type tReadResp = (src: Server, messages: seq[int]);
event eReadResp: tReadResp;

machine Client {
    var servers : set[Server];
    var numMessagesBroadcast: int;
    var MaxMessagesBroadcast: int;
    var nextId : int;

    fun SomeValue() : int {
        return choose(100) + 1;
    }

    start state Init {
        entry (input : (servers : set[Server], MaxMessagesBroadcast: int)) {
            assert sizeof(input.servers) > 0;
            assert input.MaxMessagesBroadcast > 0;
            MaxMessagesBroadcast = input.MaxMessagesBroadcast;
            numMessagesBroadcast = 0;
            nextId = 0;
            servers = input.servers;
            goto SendBroadcast;
        }
    }

    state SendBroadcast {
        entry {
            if (numMessagesBroadcast >= MaxMessagesBroadcast) {
                goto ReadResult;
            } else if (numMessagesBroadcast < MaxMessagesBroadcast) {
                send choose(servers), eBroadcastReq, (src = this, message = SomeValue(), msg_id = nextId);
                numMessagesBroadcast = numMessagesBroadcast + 1;
                nextId = nextId + 1;
                goto SendBroadcast;
            }
        }
    }

    state ReadResult {
        entry {
            send choose(servers), eReadReq, (src = this,);
            receive { 
                case eReadResp: (resp: tReadResp) {}
            }
        }

        on eBroadcastResp do {}
    }
}