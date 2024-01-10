spec EchoMessageIsAlwaysUnchanged observes eEchoReq, eEchoResp {
    var echoed_values : map[int, int];
    start state WaitForEchoReqAndResp {
        on eEchoReq do (req: tEchoReq) {
            echoed_values[req.msg_id] = req.echo;
        }

        on eEchoResp do (resp : tEchoResp) {
            assert resp.echo == echoed_values[resp.in_reply_to],
                format ("client sent {0}, received {1}", echoed_values[resp.in_reply_to], resp.echo);
        }
    }
}