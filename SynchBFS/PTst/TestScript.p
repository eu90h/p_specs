test tcSingleClient [main=TestWithSingleClientWithNoFailures]:
  assert CheckDFSTreeInvariants in
  (union Node, RoundOrchestrator, { TestWithSingleClientWithNoFailures });