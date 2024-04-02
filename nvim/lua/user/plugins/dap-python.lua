return {
  "mfussenegger/nvim-dap-python",
  config = function()
    if os.getenv "USER" == "vitorh" then
      if os.getenv "MAYA_LOCATION" ~= nil then
        require("dap-python").setup(os.getenv "MAYA_LOCATION" .. "/bin/python-bin")
        vim.notify "Loading maya python interpreter"
      else
        vim.notify "Loading python interpreter"
        require("dap-python").setup(os.getenv "PYTHON_EXE")
      end
    else
      require("dap-python").setup "python"
    end
  end,
}
