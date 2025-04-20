-- AstroCommunity: import any community modules here
-- We import this file in `lazy_setup.lua` before the `plugins/` folder.
-- This guarantees that the specs are processed before any user plugins.

---@type LazySpec
return {
  "AstroNvim/astrocommunity",
  { import = "astrocommunity.pack.lua" },
  { import = "astrocommunity.pack.cpp" }, -- Add CPP extensions
  { import = "astrocommunity.pack.go" },  -- Add Go extensions
  { import = "astrocommunity.pack.java" }, -- Add Java extensions
  { import = "astrocommunity.colorscheme.catppuccin" },
  -- import/override with your plugins folder
}
