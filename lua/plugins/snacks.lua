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
          files = {
            hidden = true,
            ignored = true,
          },
          grep = {
            hidden = true,
            ignored = true,
          },
          explorer = {
            hidden = true,
            include = {
              "node_modules",
            },
          },
        },
      },
      explorer = {
        hidden = true,
      },
    },
  },
}
