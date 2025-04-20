-- File: ~/.config/nvim/lua/plugins/debugging.lua

return {
  -- Add the DAP (Debug Adapter Protocol) plugin
  {
    "mfussenegger/nvim-dap",
    event = "VeryLazy",
    config = function()
      -- Set up key mappings for debugging
      local keymap = vim.keymap.set
      -- Toggle breakpoint
      keymap("n", "<leader>db", function() require("dap").toggle_breakpoint() end, { desc = "Toggle Breakpoint" })
      -- Start/continue debugging
      keymap("n", "<leader>dc", function() require("dap").continue() end, { desc = "Start/Continue Debugging" })
      -- Step over
      keymap("n", "<leader>ds", function() require("dap").step_over() end, { desc = "Step Over" })
      -- Step into
      keymap("n", "<leader>di", function() require("dap").step_into() end, { desc = "Step Into" })
      -- Step out
      keymap("n", "<leader>do", function() require("dap").step_out() end, { desc = "Step Out" })
      -- Close debugging
      keymap("n", "<leader>dx", function() require("dap").terminate() end, { desc = "Terminate Debug Session" })
    end,
  },

  -- Add the Go debugging extension for nvim-dap
  {
    "leoluz/nvim-dap-go",
    ft = "go", -- Only load for Go files
    dependencies = { "mfussenegger/nvim-dap" },
    config = function()
      require("dap-go").setup()

      -- Add Go-specific debug mappings
      local keymap = vim.keymap.set
      keymap("n", "<leader>dt", function() require("dap-go").debug_test() end, { desc = "Debug Go Test" })
      keymap("n", "<leader>dl", function() require("dap-go").debug_last_test() end, { desc = "Debug Last Go Test" })
    end,
  },

  -- Add Debug Adapter UI
  {
    "rcarriga/nvim-dap-ui",
    dependencies = { "mfussenegger/nvim-dap" },
    config = function()
      local dapui = require "dapui"
      dapui.setup {
        -- Default configuration for layouts
        layouts = {
          {
            elements = {
              -- Elements can be strings or table with id and size keys.
              { id = "scopes", size = 0.25 },
              "breakpoints",
              "stacks",
              "watches",
            },
            size = 40, -- 40 columns
            position = "left",
          },
          {
            elements = {
              "repl",
              "console",
            },
            size = 0.25, -- 25% of total lines
            position = "bottom",
          },
        },
      }

      -- Automatically open UI when debugging starts
      local dap = require "dap"
      dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
      dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
      dap.listeners.before.event_exited["dapui_config"] = function() dapui.close() end

      -- Key bindings for UI
      local keymap = vim.keymap.set
      keymap("n", "<leader>du", function() dapui.toggle() end, { desc = "Toggle Debug UI" })
      keymap("n", "<leader>de", function() dapui.eval() end, { desc = "Evaluate Expression" })
      keymap("v", "<leader>de", function() dapui.eval() end, { desc = "Evaluate Selection" })
    end,
  },

  -- Add DAP virtual text (show values during debugging)
  {
    "theHamsta/nvim-dap-virtual-text",
    dependencies = { "mfussenegger/nvim-dap" },
    config = function()
      require("nvim-dap-virtual-text").setup {
        enabled = true,
        enabled_commands = true,
        highlight_changed_variables = true,
        highlight_new_as_changed = false,
        show_stop_reason = true,
        commented = false,
        virt_text_pos = "eol",
        all_frames = false,
      }
    end,
  },
}
