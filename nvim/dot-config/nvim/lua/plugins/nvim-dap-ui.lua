return {
  "rcarriga/nvim-dap-ui",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-neotest/nvim-nio",
  },
  keys = {
    { "<leader>dv", function() require("dapui").toggle() end, desc = "Toggle Debug View" },
  },
  config = function()
    local dapui = require("dapui")
    dapui.setup()

    local dap = require("dap")
    -- Open UI automatically when debugging starts
    dap.listeners.after.event_initialized["dapui_config"] = function()
      dapui.open()
    end

    -- Close UI automatically when debugging stops or exits
    dap.listeners.before.event_terminated["dapui_config"] = function()
      dapui.close()
    end
    dap.listeners.before.event_exited["dapui_config"] = function()
      dapui.close()
    end

  end,
}

