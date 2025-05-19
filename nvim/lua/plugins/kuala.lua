return {
  "mistweaverco/kulala.nvim",
  keys = {
    { "<leader><leader>rs", desc = "Send request" },
    { "<leader><leader>ra", desc = "Send all requests" },
    { "<leader><leader>rb", desc = "Open scratchpad" },
  },
  ft = { "http", "rest" },
  opts = {
    -- your configuration comes here
    global_keymaps = true,

    contenttypes = {
      ["application/vnd.pypi.simple.v1+json"] = {
        ft = "json",
        formatter = vim.fn.executable "jq" == 1 and { "jq", "." },
        pathresolver = function(...) return require("kulala.parser.jsonpath").parse(...) end,
      },
      ["application/json"] = {
        ft = "json",
        formatter = vim.fn.executable "jq" == 1 and { "jq", "." },
        pathresolver = function(...) return require("kulala.parser.jsonpath").parse(...) end,
      },
      ["application/xml"] = {
        ft = "xml",
        formatter = vim.fn.executable "xmllint" == 1 and { "xmllint", "--format", "-" },
        pathresolver = vim.fn.executable "xmllint" == 1 and { "xmllint", "--xpath", "{{path}}", "-" },
      },
      ["text/html"] = {
        ft = "html",
        formatter = vim.fn.executable "xmllint" == 1 and { "xmllint", "--format", "--html", "-" },
        pathresolver = nil,
      },
    },
  },
}
