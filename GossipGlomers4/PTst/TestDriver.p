machine TestWithSingleClientWithNoFailures {
    start state Init {
        entry {
            var client: Client;
            var topology: map[Server, set[Server]];
            var servers: set[Server];
            var neighbors1 : set[Server];
            var neighbors2 : set[Server];
            var neighbors3 : set[Server];
            var n1: Server;
            var n2: Server;
            var n3: Server;

            n1 = new Server((isNetworkUnreliable = false,));
            n2 = new Server((isNetworkUnreliable = false,));
            n3 = new Server((isNetworkUnreliable = false,));
            
            servers += (n1);
            servers += (n2);
            servers += (n3);

            neighbors1 += (n2);
            neighbors1 += (n3);
            topology[n1] = neighbors1;

            neighbors2 += (n1);
            neighbors3 += (n1);
            neighbors3 += (n2);
            topology[n2] = neighbors2;
            topology[n3] = neighbors3;

            send n1, eTopologyMsg, (topology = topology, allServers = servers);
            send n2, eTopologyMsg, (topology = topology, allServers = servers);
            send n3, eTopologyMsg, (topology = topology, allServers = servers);

            client = new Client((servers = servers, MaxMessagesBroadcast = 100));
        }
    }
}

machine TestWithSingleClientWithUnreliableNetwork {
    start state Init {
        entry {
            var client: Client;
            var topology: map[Server, set[Server]];
            var servers: set[Server];
            var neighbors1 : set[Server];
            var neighbors2 : set[Server];
            var neighbors3 : set[Server];
            var n1: Server;
            var n2: Server;
            var n3: Server;

            n1 = new Server((isNetworkUnreliable = true,));
            n2 = new Server((isNetworkUnreliable = true,));
            n3 = new Server((isNetworkUnreliable = true,));
            
            servers += (n1);
            servers += (n2);
            servers += (n3);

            neighbors1 += (n2);
            neighbors1 += (n3);
            topology[n1] = neighbors1;

            neighbors2 += (n1);
            neighbors2 += (n3);
            neighbors3 += (n1);
            neighbors3 += (n2);
            topology[n2] = neighbors2;
            topology[n3] = neighbors3;

            send n1, eTopologyMsg, (topology = topology, allServers = servers);
            send n2, eTopologyMsg, (topology = topology, allServers = servers);
            send n3, eTopologyMsg, (topology = topology, allServers = servers);

            client = new Client((servers = servers, MaxMessagesBroadcast = 10));
        }
    }
}