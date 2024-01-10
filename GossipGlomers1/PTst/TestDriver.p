machine TestWithSingleClient {
    start state Init {
        entry {
            var server : Server;
            server = new Server();
            new Client((server = server,));
        }
    }
}