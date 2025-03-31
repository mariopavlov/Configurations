-- File: ~/.config/nvim/lua/plugins/lazygit.lua

return {
  -- Add the LazyGit plugin
  {
    "kdheepak/lazygit.nvim",
    -- Load only when needed
    cmd = {
      "LazyGit",
      "LazyGitConfig",
      "LazyGitCurrentFile",
      "LazyGitFilter",
      "LazyGitFilterCurrentFile",
    },
    -- Dependencies
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    -- Configuration
    config = function()
      -- Custom mappings
      vim.keymap.set("n", "<leader>gg", "<cmd>LazyGit<CR>", { desc = "LazyGit" })
      vim.keymap.set("n", "<leader>gf", "<cmd>LazyGitFilter<CR>", { desc = "LazyGit File History" })
      vim.keymap.set("n", "<leader>gc", "<cmd>LazyGitConfig<CR>", { desc = "LazyGit Config" })

      -- Optional configuration options
      vim.g.lazygit_floating_window_winblend = 0 -- transparency of floating window
      vim.g.lazygit_floating_window_scaling_factor = 0.9 -- scaling factor for floating window
      vim.g.lazygit_floating_window_corner_chars = { "╭", "╮", "╰", "╯" } -- customize floating window corner characters
      vim.g.lazygit_floating_window_use_plenary = 0 -- use plenary.nvim to manage floating window if available
      vim.g.lazygit_use_neovim_remote = 1 -- fallback to 0 if neovim-remote is not installed

      -- Set custom lazygit config path if needed
      -- vim.g.lazygit_config_file_path = vim.fn.expand("~/.config/lazygit/config.yml")
    end,
  },

  -- You can also add this to your AstroNvim user configuration for keybindings
  -- This block would go in your mappings.lua file
  -- {
  --   n = {
  --     ["<leader>gg"] = { "<cmd>LazyGit<CR>", desc = "LazyGit" },
  --     ["<leader>gf"] = { "<cmd>LazyGitFilter<CR>", desc = "LazyGit File History" },
  --     ["<leader>gc"] = { "<cmd>LazyGitConfig<CR>", desc = "LazyGit Config" },
  --   },
  -- },
}
