test tcSingleClientNoFailures [main=TestWithSingleClientWithNoFailures]:
  assert ReadReturnsBroadcastedValues, AllBroadcastsReceiveResponses in
  (union Client, Server, { TestWithSingleClientWithNoFailures });

test tcSingleClientFailures [main=TestWithSingleClientWithFailures]:
  assert ReadReturnsBroadcastedValues, AllBroadcastsReceiveResponses in
  (union Client, Server, FailureInjector, { TestWithSingleClientWithFailures });

test tcSingleClientWithUnreliableNetwork [main=TestWithSingleClientWithUnreliableNetwork]:
assert ReadReturnsBroadcastedValues, AllBroadcastsReceiveResponses in
(union Client, Server, { TestWithSingleClientWithUnreliableNetwork });