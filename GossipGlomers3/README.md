This spec is intended to model Gossip Glomers challenge 3a/b/c. Click [here](https://fly.io/dist-sys/3c/) for the original problem statement.
There are currently two tests:

* `tcSingleClientNoFailures`: single client, multiple servers, with no machine failures and reliable network.

* `tcSingleClientFailures`: single client, multple servers, with machine failures and reliable network. Currently this test case doesn't pass.

* `tcSingleClientWithUnreliableNetwork`: single client, multiple servers. Messages between servers can fail. For simplicity, messages to the client are reliable. Machines cannot fail. Since machines don't fail, it's assumed messages are delivered eventually.