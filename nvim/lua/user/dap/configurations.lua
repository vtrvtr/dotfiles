return {
  python =
  {
    name = "Pytest: Current File",
    type = "python",
    request = "launch",
    module = "unittest",
    args = {
      "${file}",
      "-sv",
      "--log-cli-level=INFO",
      "--log-file=test_out.log"
    },
    console = "integratedTerminal",
  }
}
