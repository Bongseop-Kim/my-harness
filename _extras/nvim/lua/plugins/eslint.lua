return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        eslint = {
          settings = {
            useFlatConfig = false,
            experimental = {
              useFlatConfig = false,
            },
            workingDirectory = {
              mode = "auto",
            },
          },
        },
      },
    },
  },
}
