test tcSingleClient [main=TestWithSingleClientWithNoFailures]:
  assert EnsureDistancesAreMinimized in
  (union Node, RoundOrchestrator, { TestWithSingleClientWithNoFailures });