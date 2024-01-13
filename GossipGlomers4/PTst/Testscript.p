test tcSingleClient [main=TestWithSingleClientWithNoFailures]:
  assert ReadReturnsSumOfValues, AllBroadcastsReceiveResponses in
  (union Client, Server, Timer, { TestWithSingleClientWithNoFailures });

test tcSingleClientUnreliableNetwork [main=TestWithSingleClientWithUnreliableNetwork]:
  assert ReadReturnsSumOfValues, AllBroadcastsReceiveResponses in
  (union Client, Server, Timer, { TestWithSingleClientWithUnreliableNetwork });