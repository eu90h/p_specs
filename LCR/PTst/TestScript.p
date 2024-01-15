test tcSingleClient [main=TestWithSingleClientWithNoFailures]:
  assert OnlyOneLeader, AllNodeIdentificationMessagesReceiveResponses in
  (union Node, { TestWithSingleClientWithNoFailures });