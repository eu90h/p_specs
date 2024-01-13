test tcSingleClientNoFailures [main=TestWithSingleClientWithNoFailures]:
  assert ReadReturnsBroadcastedValues, AllBroadcastsReceiveResponses in
  (union Client, Server, Timer, { TestWithSingleClientWithNoFailures });

test tcSingleClientFailures [main=TestWithSingleClientWithFailures]:
  assert ReadReturnsBroadcastedValues, AllBroadcastsReceiveResponses in
  (union Client, Server, Timer, FailureInjector, { TestWithSingleClientWithFailures });

test tcSingleClientWithUnreliableNetwork [main=TestWithSingleClientWithUnreliableNetwork]:
  assert ReadReturnsBroadcastedValues, AllBroadcastsReceiveResponses in
  (union Client, Server, Timer, { TestWithSingleClientWithUnreliableNetwork });