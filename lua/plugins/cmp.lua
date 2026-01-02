return {
  {
    "saghen/blink.cmp",
    opts = {
      keymap = { preset = "super-tab" },
      completion = {
        menu = { border = "single" },
        documentation = { window = { border = "single" } },
        ghost_text = {
          enabled = true,
          show_without_selection = true,
          show_with_menu = true,
          show_without_menu = true,
        },
        list = {
          selection = { preselect = true, auto_insert = false },
        },
      },
      signature = { window = { border = "single" } },
    },
    config = function(_, opts)
      require("blink.cmp").setup(opts)
      vim.api.nvim_set_hl(0, "BlinkCmpGhostText", { link = "DraculaComment" })
    end,
  },
}
