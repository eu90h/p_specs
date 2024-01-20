test tcSingleClient [main=TestWithSingleClientWithNoFailures]:
  assert OnlyOneLeader in
  (union Node, RoundOrchestrator, { TestWithSingleClientWithNoFailures });