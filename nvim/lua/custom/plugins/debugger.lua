return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "mfussenegger/nvim-dap-python",
      "theHamsta/nvim-dap-virtual-text",
      "nvim-neotest/nvim-nio",
    },
    config = function()
      local dap = require("dap")
      local dap_python = require("dap-python")
      local dapui = require("dapui")

      -- 1) set up the Python adapter (with frozen_modules off if you added that earlier):
      dap.adapters.python = {
        type = "executable",
        command = "python3",
        args = { "-Xfrozen_modules=off", "-m", "debugpy.adapter" },
      }

      -- 2) tell DAP to launch your file and send stdin to an "integratedTerminal"
      dap.configurations.python = {
        {
          type = "python", -- matches the adapter name above
          request = "launch",
          name = "Launch file with stdin",
          program = "${file}", -- debug the current buffer
          console = "integratedTerminal", -- ← this is the key!
          pythonPath = function()
            return "python3" -- or point to your venv/python
          end,
        },
      }

      -- 3) (optional) set up dap-python helper if you still want it:
      dap_python.setup("python3")

      -- 4) dap-ui and listeners:
      dapui.setup()
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end

      -- 5) your keymaps (make sure they’re after you `require("dap")`):
      vim.keymap.set("n", "<space>b", dap.toggle_breakpoint, { desc = "DAP: toggle breakpoint" })
      vim.keymap.set("n", "<space>gb", dap.run_to_cursor, { desc = "DAP: run to cursor" })
      vim.keymap.set("n", "<space>dc", dap.continue, { desc = "DAP: start/continue" })
      vim.keymap.set("n", "<space>dn", dap.step_over, { desc = "DAP: step over" })
      vim.keymap.set("n", "<space>di", dap.step_into, { desc = "DAP: step into" })
      vim.keymap.set("n", "<space>do", dap.step_out, { desc = "DAP: step out" })
      vim.keymap.set("n", "<space>dq", dap.terminate, { desc = "DAP: terminate" })
    end,
  },
}
