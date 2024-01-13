type tAdd = (src: Client, delta: int, msg_id: int);
event eAdd : tAdd;

type tAddResp = (src: Server, in_response_to: int);
event eAddResp: tAddResp;

type tReadReq = (src: Client, msg_id: int);
event eReadReq : tReadReq;

type tReadResp = (src: Server, value: int, in_response_to: int);
event eReadResp: tReadResp;

machine Client {
    var servers : set[Server];
    var numMessagesBroadcast: int;
    var numBroadcastResponses: int;
    var MaxMessagesBroadcast: int;

    fun SomeValue() : int {
        return choose(100) + 1;
    }

    start state Init {
        entry (input : (servers : set[Server], MaxMessagesBroadcast: int)) {
            assert sizeof(input.servers) > 0;
            assert input.MaxMessagesBroadcast > 0;
            MaxMessagesBroadcast = input.MaxMessagesBroadcast;
            numMessagesBroadcast = 0;
            numBroadcastResponses= 0;
            servers = input.servers;
            goto SendBroadcast;
        }
    }

    state SendBroadcast {
        entry {
            if (numBroadcastResponses >= MaxMessagesBroadcast) {
                goto ReadResult;
            } else if (numMessagesBroadcast < MaxMessagesBroadcast) {
                send choose(servers), eAdd, (src = this, delta = SomeValue(), msg_id = RandomID());
                numMessagesBroadcast = numMessagesBroadcast + 1;
            }
        }

        on eAddResp do {
            numBroadcastResponses = numBroadcastResponses + 1;
            goto SendBroadcast;
        }
    }

    state ReadResult {
        entry {
            send choose(servers), eReadReq, (src = this, msg_id = RandomID());
        }

        on eReadResp do {}
    }
}