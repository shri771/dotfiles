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
      vim.keymap.set("n", "<space>dc", dap.continue, { desc = "DAP: start/continue" })
      vim.keymap.set("n", "<space>b", dap.toggle_breakpoint, { desc = "DAP: toggle breakpoint" })

      -- when a debug session starts
      dap.listeners.after.event_initialized["custom_keymaps"] = function(session, body)
        -- buffer-local keymaps in the current file/buffer
        local opts = { buffer = 0, desc = "DAP debug key" }
        vim.keymap.set("n", "n", dap.step_over, vim.tbl_extend("force", opts, { desc = "DAP: Step Over" }))
        vim.keymap.set("n", "i", dap.step_into, vim.tbl_extend("force", opts, { desc = "DAP: Step Into" }))
        vim.keymap.set("n", "o", dap.step_out, vim.tbl_extend("force", opts, { desc = "DAP: Step Out" }))
        vim.keymap.set("n", "c", dap.continue, vim.tbl_extend("force", opts, { desc = "DAP: Continue" }))
        vim.keymap.set(
          "n",
          "b",
          dap.toggle_breakpoint,
          vim.tbl_extend("force", opts, { desc = "DAP: Toggle Breakpoint" })
        )
        vim.keymap.set("n", "q", dap.terminate, vim.tbl_extend("force", opts, { desc = "DAP: Terminate" }))
      end

      -- when a debug session ends
      local clear = function()
        for _, key in ipairs({ "n", "i", "o", "c", "b", "q" }) do
          pcall(vim.api.nvim_buf_del_keymap, 0, "n", key)
        end
      end
      dap.listeners.before.event_terminated["custom_keymaps"] = clear
      dap.listeners.before.event_exited["custom_keymaps"] = clear
    end,
  },
}
