test tcSingleClient [main=TestWithSingleClientWithNoFailures]:
  assert CheckBFSTreeInvariants in
  (union Node, RoundOrchestrator, { TestWithSingleClientWithNoFailures });