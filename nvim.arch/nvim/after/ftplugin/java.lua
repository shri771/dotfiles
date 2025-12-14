local jdtls = require("jdtls")
local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
local workspace_dir = vim.env.HOME .. "/.cache/jdtls/workspace/" .. project_name

-- Helper to find mason package paths
local function get_mason_package_path(package)
  local path = vim.fn.stdpath("data") .. "/mason/packages/" .. package
  return path
end

local jdtls_path = get_mason_package_path("jdtls")
local launcher_jar = vim.fn.glob(jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar")
local config_dir = jdtls_path .. "/config_linux"

-- Main Config
local config = {
  cmd = {
    "java",
    "-Declipse.application=org.eclipse.jdt.ls.core.id1",
    "-Dosgi.bundles.defaultStartLevel=4",
    "-Declipse.product=org.eclipse.jdt.ls.core.product",
    "-Dlog.protocol=true",
    "-Dlog.level=ALL",
    "-Xms1g",
    "--add-modules=ALL-SYSTEM",
    "--add-opens", "java.base/java.util=ALL-UNNAMED",
    "--add-opens", "java.base/java.lang=ALL-UNNAMED",
    "-jar", launcher_jar,
    "-configuration", config_dir,
    "-data", workspace_dir,
  },
  root_dir = require("jdtls.setup").find_root({ ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" }),
  
  settings = {
    java = {
      errors = {
        incompleteClasspath = {
          severity = "warning",
        },
      },
      configuration = {
        runtimes = {
          -- Configure runtimes if needed
        },
      },
    },
  },

  -- Capabilities from blink.cmp
  capabilities = require("blink.cmp").get_lsp_capabilities(),
  
  on_attach = function(client, bufnr)
    if client.name == "jdtls" then
      require("jdtls").setup_dap({ hotcodereplace = "auto" })
      require("jdtls.dap").setup_dap_main_class_configs()
    end
  end,
}

-- Add the debug adapter bundle if installed
local java_debug_path = get_mason_package_path("java-debug-adapter")
local debug_jar = vim.fn.glob(java_debug_path .. "/extension/server/com.microsoft.java.debug.plugin-*.jar")

if debug_jar ~= "" then
  local bundles = { debug_jar }
  config.init_options = {
    bundles = bundles
  }
end

-- Start the server
jdtls.start_or_attach(config)
