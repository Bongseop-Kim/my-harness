return {
  "mikavilpas/yazi.nvim",
  event = "VeryLazy",
  keys = {
    {
      "<leader>-",
      "<cmd>Yazi<cr>",
      desc = "Open yazi (file dir)",
    },
    {
      "<leader>E",
      "<cmd>Yazi cwd<cr>",
      desc = "Open yazi (project root)",
    },
  },
  opts = {
    open_for_directories = true,
    floating_window_scaling_factor = 0.85,
    yazi_floating_window_border = "rounded",
  },
}
