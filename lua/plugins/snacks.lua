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
            ignored = false,
          },
          grep = {
            hidden = true,
            ignored = false,
          },
          explorer = {
            hidden = true,
            include = {
              ".git",
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
