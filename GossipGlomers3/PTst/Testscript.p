test tcSingleClient [main=TestWithSingleClient]:
  assert ReadReturnsBroadcastedValues in
  (union Client, Server, { TestWithSingleClient });