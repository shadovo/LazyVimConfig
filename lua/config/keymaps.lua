-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Run project-wide eslint and svelte-check
vim.keymap.set("n", "<leader>xe", function()
  require("config.linting").lint_project()
end, { desc = "Eslint Project" })
