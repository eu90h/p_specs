type tBroadcastReq = (src: Client, message: int);
event eBroadcastReq : tBroadcastReq;

type tBroadcastResp = (src: Server);
event eBroadcastResp: tBroadcastResp;

type tReadReq = (src: Client);
event eReadReq : tReadReq;

type tReadResp = (src: Server, messages: seq[int]);
event eReadResp: tReadResp;

machine Client {
    var servers : set[Server];
    var numMessagesBroadcast: int;
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
            servers = input.servers;
            goto SendBroadcast;
        }
    }

    state SendBroadcast {
        entry {
            var someServer : Server;
            var x : int;

            someServer = choose(servers);
            x = SomeValue();
            send someServer, eBroadcastReq, (src = this, message = x);
        }

        on eBroadcastResp do (resp : tBroadcastResp) {
            numMessagesBroadcast = numMessagesBroadcast + 1;
            if (numMessagesBroadcast < MaxMessagesBroadcast) {
                goto SendBroadcast;
            } else {
                goto ReadResult;
            }
        }
    }

    state ReadResult {
        entry {
            send choose(servers), eReadReq, (src = this,);
        }

        on eReadResp do (resp: tReadResp) {}
    }
}