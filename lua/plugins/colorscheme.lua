return {

  {
    "dracula/vim",
    name = "dracula", -- This gives it a specific name in case it's ever needed
    lazy = false, -- Load this theme immediately
    priority = 1000, -- Ensure it's loaded before other plugins
    config = function()
      vim.cmd.colorscheme("dracula")

      vim.api.nvim_set_hl(0, "@markup.heading.1.markdown", { link = "DraculaPurple" })
      vim.api.nvim_set_hl(0, "@markup.heading.2.markdown", { link = "DraculaGreen" })
      vim.api.nvim_set_hl(0, "@markup.heading.3.markdown", { link = "DraculaYellow" })
      vim.api.nvim_set_hl(0, "@markup.heading.4.markdown", { link = "DraculaOrange" })
      vim.api.nvim_set_hl(0, "@markup.heading.5.markdown", { link = "DraculaCyan" })
      vim.api.nvim_set_hl(0, "@markup.heading.6.markdown", { link = "DraculaCyan" })
      vim.api.nvim_set_hl(0, "@markup.link.markdown_inline", { link = "DraculaOrange" })
      vim.api.nvim_set_hl(0, "@markup.link.url.markdown_inline", { link = "DraculaCyan" })
      vim.api.nvim_set_hl(0, "@markup.link.label.markdown_inline", { link = "DraculaPink" })

      vim.api.nvim_set_hl(0, "RenderMarkdownH1Bg", { fg = "#BD93F9", bg = "#36354a" })
      vim.api.nvim_set_hl(0, "RenderMarkdownH2Bg", { fg = "#50FA7B", bg = "#2d403e" })
      vim.api.nvim_set_hl(0, "RenderMarkdownH3Bg", { fg = "#F1FA8C", bg = "#3d3f3f" })
      vim.api.nvim_set_hl(0, "RenderMarkdownH4Bg", { fg = "#FFB86C", bg = "#3e393c" })
      vim.api.nvim_set_hl(0, "RenderMarkdownH5Bg", { fg = "#8BE9FD", bg = "#323d4a" })
      vim.api.nvim_set_hl(0, "RenderMarkdownH6Bg", { fg = "#8BE9FD", bg = "#323d4a" })

      vim.api.nvim_set_hl(0, "DraculaSubtle", { fg = "#6272a4" })
      -- vim.api.nvim_set_hl(0, "SnacksPickerPathHidden", { fg = "#6272a4" })
      vim.api.nvim_set_hl(0, "SnacksPickerPathHidden", { link = "Normal" })
    end,
  },
}
