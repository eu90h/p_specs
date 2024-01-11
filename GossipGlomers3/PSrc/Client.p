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

    fun SomeValue() : int {
        return choose(100) + 1;
    }

    start state Init {
        entry (input : (servers : set[Server])) {
            numMessagesBroadcast = 0;
            servers = input.servers;
            assert sizeof(servers) > 0;
            goto BroadcastingAndReading;
        }
    }

    state BroadcastingAndReading {
        entry {
            var someServer : Server;
            var x : int;

            foreach (someServer in servers) {
                x = SomeValue();
                send someServer, eBroadcastReq, (src = this, message = x);
            }
        }

        on eBroadcastResp do (resp : tBroadcastResp) {
            var someServer : Server;
            var x : int;

            numMessagesBroadcast = numMessagesBroadcast + 1;
            if (numMessagesBroadcast >= 10) {
                someServer = choose(servers);
                send someServer, eReadReq, (src = this,);
            } else {
                x = SomeValue();
                someServer = choose(servers);
                send someServer, eBroadcastReq, (src = this, message = x);
            }
        }

        on eReadResp do (resp: tReadResp) {}
    }
}