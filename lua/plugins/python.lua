return {
    {
      "linux-cultist/venv-selector.nvim",
      dependencies = { 
        "neovim/nvim-lspconfig", 
        "nvim-telescope/telescope.nvim",
        "mfussenegger/nvim-dap-python",
       },
      config = function()
        require("venv-selector").setup({
          name = {
            "venv",
            ".venv",
            "env",
            ".env"
          }, 
          auto_refresh = true,
          parents = 0,
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
      -- Existing Python plugins...

      -- Add LuaSnip for snippets
      {
        "L3MON4D3/LuaSnip",
        dependencies = {
            "rafamadriz/friendly-snippets",
        },
        config = function()
            require("luasnip.loaders.from_vscode").lazy_load()
        end,
    },

    -- Add nvim-cmp for completion
    {
        "hrsh7th/nvim-cmp",
        event = "InsertEnter",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "saadparwaiz1/cmp_luasnip",
            "hrsh7th/cmp-nvim-lsp-signature-help",
        },
        config = function()
            local cmp = require("cmp")
            local luasnip = require("luasnip")

            cmp.setup({
                snippet = {
                    expand = function(args)
                        luasnip.lsp_expand(args.body)
                    end,
                },
                mapping = cmp.mapping.preset.insert({
                    ["<C-d>"] = cmp.mapping.scroll_docs(-4),
                    ["<C-f>"] = cmp.mapping.scroll_docs(4),
                    ["<C-Space>"] = cmp.mapping.complete(),
                    ["<CR>"] = cmp.mapping.confirm({
                        behavior = cmp.ConfirmBehavior.Replace,
                        select = true,
                    }),
                    ["<Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_next_item()
                        elseif luasnip.expand_or_jumpable() then
                            luasnip.expand_or_jump()
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                    ["<S-Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_prev_item()
                        elseif luasnip.jumpable(-1) then
                            luasnip.jump(-1)
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                }),
                sources = {
                    { name = "nvim_lsp" },
                    { name = "luasnip" },
                    { name = "buffer" },
                    { name = "path" },
                    { name = "nvim_lsp_signature_help" },
                },
            })
        end,
    },
  }