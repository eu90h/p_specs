test tcSingleClient [main=TestWithSingleClient]:
  assert EchoMessageIsAlwaysUnchanged in
  (union Client, Server, { TestWithSingleClient });