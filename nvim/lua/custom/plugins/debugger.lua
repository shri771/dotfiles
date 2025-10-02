return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "mfussenegger/nvim-dap-python",
      "theHamsta/nvim-dap-virtual-text",
      "nvim-neotest/nvim-nio",
      "mfussenegger/nvim-jdtls",
      "microsoft/vscode-java-debug",
      "leoluz/nvim-dap-go", -- Go debugging support
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")
      local dap_python = require("dap-python")
      local dap_go = require("dap-go")

      -- Dynamic Python path
      local function resolve_python()
        local venv = os.getenv("VIRTUAL_ENV")
        if venv then
          return venv .. "/bin/python"
        end
        return vim.fn.exepath("python3") or "python"
      end

      -- Python DAP Adapter and Configuration
      dap.adapters.python = {
        type = "executable",
        command = resolve_python(),
        args = { "-Xfrozen_modules=off", "-m", "debugpy.adapter" },
      }
      dap.configurations.python = {
        {
          type = "python",
          request = "launch",
          name = "Launch Python file",
          program = "${file}",
          console = "integratedTerminal",
          pythonPath = resolve_python,
        },
      }
      dap_python.setup(resolve_python())

      -- Go DAP Setup (using Delve)
      dap_go.setup()

      -- Java DAP Adapter (using nvim-jdtls)
      dap.adapters.java = function(callback)
        require("jdtls").setup_dap({ hotcodereplace = "auto" })
        callback({ type = "server", host = "127.0.0.1", port = 5005 })
      end

      -- Java DAP Configuration (dynamic, python-like)
      dap.configurations.java = {
        {
          type = "java",
          request = "launch",
          name = "Launch Java file",
          -- Prompt main class like 'program' in Python config
          mainClass = function()
            return vim.fn.input("Main class (e.g. com.example.Main): ")
          end,
          projectName = function()
            return vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
          end,
          cwd = "${workspaceFolder}",
          console = "integratedTerminal", -- mimic Python's terminal behavior
          stopOnEntry = false,
        },
      }

      -- DAP UI and Listeners
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

      -- Global keymaps
      vim.keymap.set("n", "<space>dc", dap.continue, { desc = "DAP: start/continue" })
      vim.keymap.set("n", "<space>b", dap.toggle_breakpoint, { desc = "DAP: toggle breakpoint" })

      -- Dynamic buffer-local keymaps on debug session start (Python AND Java)
      dap.listeners.after.event_initialized["custom_keymaps"] = function(session, body)
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
