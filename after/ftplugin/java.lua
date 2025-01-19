local status, jdtls = pcall(require, "jdtls")
if not status then
  return
end

local home = vim.env.HOME
local mason_registry = require("mason-registry")
local jdtls_pkg = mason_registry.get_package("jdtls")
local jdtls_path = jdtls_pkg:get_install_path()
local launcher = vim.fn.glob(jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar")

-- Find root directory
local root_markers = { ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" }
local root_dir = require("jdtls.setup").find_root(root_markers)
if root_dir == "" then
  return
end

local project_name = vim.fn.fnamemodify(root_dir, ":p:h:t")
local workspace_dir = home .. "/.cache/jdtls/workspace/" .. project_name

-- Get system config
local os_config = "linux"
if vim.fn.has("mac") == 1 then
  os_config = "mac"
elseif vim.fn.has("win32") == 1 then
  os_config = "win"
end

local config = {
  cmd = {
    "java",
    "-Declipse.application=org.eclipse.jdt.ls.core.id1",
    "-Dosgi.bundles.defaultStartLevel=4",
    "-Declipse.product=org.eclipse.jdt.ls.core.product",
    "-Dlog.protocol=true",
    "-Dlog.level=ALL",
    "-Xmx1g",
    "--add-modules=ALL-SYSTEM",
    "--add-opens", "java.base/java.util=ALL-UNNAMED",
    "--add-opens", "java.base/java.lang=ALL-UNNAMED",
    "-jar", launcher,
    "-configuration", jdtls_path .. "/config_" .. os_config,
    "-data", workspace_dir,
  },

  root_dir = root_dir,

  settings = {
    java = {
      signatureHelp = { enabled = true },
      contentProvider = { preferred = "fernflower" },
      completion = {
        favoriteStaticMembers = {
          "org.junit.jupiter.api.Assertions.*",
          "java.util.Objects.requireNonNull",
          "java.util.Objects.requireNonNullElse"
        },
      },
    }
  },

  init_options = {
    bundles = {}
  },
}

-- Start JDTLS
jdtls.start_or_attach(config)

-- Keymaps
local opts = { buffer = vim.api.nvim_get_current_buf() }
vim.keymap.set("n", "<A-o>", "<cmd>lua require('jdtls').organize_imports()<cr>", opts)
vim.keymap.set("n", "crv", "<cmd>lua require('jdtls').extract_variable()<cr>", opts)
vim.keymap.set("v", "crv", "<cmd>lua require('jdtls').extract_variable(true)<cr>", opts)
vim.keymap.set("n", "crc", "<cmd>lua require('jdtls').extract_constant()<cr>", opts)
vim.keymap.set("v", "crc", "<cmd>lua require('jdtls').extract_constant(true)<cr>", opts)
vim.keymap.set("v", "crm", "<cmd>lua require('jdtls').extract_method(true)<cr>", opts)