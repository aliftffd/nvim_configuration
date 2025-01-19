return {
    {
      "linux-cultist/venv-selector.nvim",
      dependencies = { "neovim/nvim-lspconfig", "nvim-telescope/telescope.nvim" },
      config = function()
        require("venv-selector").setup({
          name = ".venv",
          auto_refresh = true
        })
      end,
      event = "VeryLazy",
      keys = {
        { "<leader>vs", "<cmd>VenvSelect<cr>", desc = "Select VirtualEnv" },
      },
    },
  
    -- Debug adapter for Python
    {
      "mfussenegger/nvim-dap-python",
      ft = "python",
      dependencies = {
        "mfussenegger/nvim-dap",
        "rcarriga/nvim-dap-ui",
      },
      config = function()
        local path = require("mason-registry")
          .get_package("debugpy")
          :get_install_path()
        require("dap-python").setup(path .. "/venv/bin/python")
      end,
    },
  
    -- Optional: Testing Framework support
    {
      "nvim-neotest/neotest",
      dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-treesitter/nvim-treesitter",
        "antoinemadec/FixCursorHold.nvim",
        "nvim-neotest/neotest-python",
      },
      config = function()
        require("neotest").setup({
          adapters = {
            require("neotest-python")({
              dap = { justMyCode = false },
              runner = "pytest",
            })
          }
        })
      end,
    },
  }