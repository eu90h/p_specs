type tEchoReq = (src: Client, msg_id: int, echo: int);
event eEchoReq : tEchoReq;

type tEchoResp = (src: Server, msg_id: int, in_reply_to: int, echo: int);
event eEchoResp : tEchoResp;

machine Client {
    var nextReqId : int;
    var server : Server;

    fun SomeValue() : int {
        return choose(100) + 1;
    }

    start state Init {
        entry (input : (server : Server )) {
            server = input.server;
            nextReqId = 0;
            goto Echoing;
        }
    }
    
    state Echoing {
        entry {
            send server, eEchoReq, (src = this, msg_id = nextReqId, echo = SomeValue());
            nextReqId = nextReqId + 1;
        }

        on eEchoResp do (resp : tEchoResp) {
            print format("client received {0}", resp.echo);
        }
    }
}