This specification describes the Le Lann-Chang-Roberts (LCR) algorithm for leader election in a synchronous ring. Details of the algorithm can be found in chapter 3 of Nancy Lynch's Distributed Algorithms textbook.

The gist of the algorithm is that each node $i\in\{1,2,\dots,N\}$ in the ring is assigned an ID number $w_i\in\{1,2,\dots,N\}$. The nodes can be started in a few ways but let's assume that they, in unison, synchronously send out messages with their ID values to their neighbor on the right. When a node receives an ID message from their neighbor on the left, they inspect the value.
* If the value is *greater than* their own ID, then they pass the message to their neighbor on the right.
* If the value is *less than* their own ID, then do nothing.
* If the value *equals* their own ID, then they are the new leader in the ring network.
