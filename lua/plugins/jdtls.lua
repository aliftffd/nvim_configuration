local function get_jdtls()
    local mason_registry = require("mason-registry")
    local jdtls = mason_registry.get_package("jdtls")
    local jdtls_path = jdtls:get_install_path()
    local launcher = vim.fn.glob(jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar")
    local SYSTEM = ""
    
    if vim.fn.has("mac") == 1 then
      SYSTEM = "mac"
    elseif vim.fn.has("unix") == 1 then
      SYSTEM = "linux"
    elseif vim.fn.has("win32") == 1 then
      SYSTEM = "win"
    end
  
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
        "-jar", launcher,
        "-configuration", jdtls_path .. "/config_" .. SYSTEM,
        "-data", vim.fn.expand("~/.cache/jdtls/workspace")
      },
      root_dir = require("jdtls.setup").find_root({ ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" }),
      settings = {
        java = {
          signatureHelp = { enabled = true },
          contentProvider = { preferred = "fernflower" },
          completion = {
            favoriteStaticMembers = {
              "org.hamcrest.MatcherAssert.assertThat",
              "org.hamcrest.Matchers.*",
              "org.hamcrest.CoreMatchers.*",
              "org.junit.jupiter.api.Assertions.*",
              "java.util.Objects.requireNonNull",
              "java.util.Objects.requireNonNullElse",
              "org.mockito.Mockito.*"
            },
            filteredTypes = {
              "com.sun.*",
              "io.micrometer.shaded.*",
              "java.awt.*",
              "jdk.*",
              "sun.*",
            },
          },
          sources = {
            organizeImports = {
              starThreshold = 9999,
              staticStarThreshold = 9999,
            },
          },
          codeGeneration = {
            toString = {
              template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}"
            },
            hashCodeEquals = {
              useJava7Objects = true,
            },
          },
          configuration = {
            runtimes = {
              {
                name = "JavaSE-17",
                path = vim.fn.expand("~/.sdkman/candidates/java/17.0.8-tem"),  -- Change this to your Java path
              },
            }
          }
        }
      },
      init_options = {
        bundles = {}
      }
    }
    
    -- Debugging setup
    local bundles = {
      vim.fn.glob(mason_registry.get_package("java-debug-adapter"):get_install_path() .. 
        "/extension/server/com.microsoft.java.debug.plugin-*.jar", 1)
    }
    
    -- Include test bundles if they exist
    vim.list_extend(bundles, vim.split(vim.fn.glob(mason_registry.get_package("java-test"):get_install_path() .. 
      "/extension/server/*.jar", 1), "\n"))
    
    config.init_options.bundles = bundles
    
    return config
  end
  
  local function setup_jdtls()
    local jdtls = require("jdtls")
    local config = get_jdtls()
    
    -- Attach the LSP
    jdtls.start_or_attach(config)
    
    -- Set up debugging
    jdtls.setup_dap({ hotcodereplace = "auto" })
    
    -- Setup key mappings
    local opts = { buffer = vim.api.nvim_get_current_buf() }
    vim.keymap.set("n", "<leader>ji", jdtls.organize_imports, opts)
    vim.keymap.set("n", "<leader>jt", jdtls.test_class, opts)
    vim.keymap.set("n", "<leader>jn", jdtls.test_nearest_method, opts)
    vim.keymap.set("v", "<leader>jem", [[<ESC><CMD>lua require('jdtls').extract_method(true)<CR>]], opts)
    vim.keymap.set("n", "<leader>jc", jdtls.extract_constant, opts)
    vim.keymap.set("v", "<leader>jev", [[<ESC><CMD>lua require('jdtls').extract_variable(true)<CR>]], opts)
    vim.keymap.set("n", "<leader>jv", jdtls.extract_variable, opts)
  end
  
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "java",
    callback = setup_jdtls
  })