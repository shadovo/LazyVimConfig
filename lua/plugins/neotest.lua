return {
  { "shadovo/neotest-bun" },
  -- { "arthur944/neotest-bun" },
  { "marilari88/neotest-vitest" },
  {
    "nvim-neotest/neotest",
    opts = {
      adapters = {
        "neotest-bun",
        "neotest-vitest",
      },
    },
  },
}
