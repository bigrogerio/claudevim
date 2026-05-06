return {
  {
    "goolord/alpha-nvim",
    event = "VimEnter",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      local alpha = require("alpha")
      local dashboard = require("alpha.themes.dashboard")

      dashboard.section.header.val = {
        [[                                                            ]],
        [[       _                 _            _                     ]],
        [[   ___| | __ _ _   _  __| | _____   _(_)_ __ ___            ]],
        [[  / __| |/ _` | | | |/ _` |/ _ \ \ / / | '_ ` _ \           ]],
        [[ | (__| | (_| | |_| | (_| |  __/\ V /| | | | | | |          ]],
        [[  \___|_|\__,_|\__,_|\__,_|\___| \_/ |_|_| |_| |_|          ]],
        [[                                                            ]],
        [[          neovim  ⨯  claude code                            ]],
        [[                                                            ]],
      }

      dashboard.section.buttons.val = {
        dashboard.button("f", "󰈞   Find file",        "<cmd>Telescope find_files<cr>"),
        dashboard.button("r", "󰋚   Recent files",     "<cmd>Telescope oldfiles<cr>"),
        dashboard.button("g", "󰱼   Live grep",        "<cmd>Telescope live_grep<cr>"),
        dashboard.button("e", "󰉋   File explorer",    "<cmd>Neotree toggle<cr>"),
        dashboard.button("c", "󰚩   Focus claude",     "<cmd>lua require('claudevim.claude').focus_claude()<cr>"),
        dashboard.button("q", "󰈆   Quit",             "<cmd>qa<cr>"),
      }

      dashboard.section.footer.val = "press <Space> to discover keymaps"

      for _, btn in ipairs(dashboard.section.buttons.val) do
        btn.opts.hl = "Function"
        btn.opts.hl_shortcut = "Type"
      end
      dashboard.section.header.opts.hl = "Keyword"
      dashboard.section.footer.opts.hl = "Comment"

      dashboard.config.layout = {
        { type = "padding", val = 2 },
        dashboard.section.header,
        { type = "padding", val = 2 },
        dashboard.section.buttons,
        { type = "padding", val = 1 },
        dashboard.section.footer,
      }

      dashboard.config.opts.noautocmd = true

      alpha.setup(dashboard.config)
    end,
  },
}
