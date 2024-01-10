machine Server {
    var nextRespId : int;
    start state HandleEcho {
        on eEchoReq do (echoReq: tEchoReq) {
            var response: tEchoResp;
            response = (src = this, msg_id = nextRespId, in_reply_to = echoReq.msg_id, echo = echoReq.echo);
            nextRespId = nextRespId + 1;
            send echoReq.src, eEchoResp, response;
        }
    }
}