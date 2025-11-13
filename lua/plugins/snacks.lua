return {
  {
    "folke/snacks.nvim",
    opts = {
      zen = {
        win = {
          backdrop = {
            transparent = false,
          },
        },
      },
      picker = {
        hidden = true,
        ignored = true,
        exclude = {
          ".git",
          "node_modules",
          ".DS_Store",
        },
        sources = {
          explorer = {
            include = {
              "node_modules",
            },
          },
        },
      },
    },
  },
}
