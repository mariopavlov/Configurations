-- lua/plugins/catppuccin.lua (or a similar name like lua/plugins/theme_opts.lua)
return {
	"catppuccin/nvim", -- This MUST match the plugin identifier
	opts = {
		-- SET YOUR FLAVOUR HERE:
		flavour = "mocha", -- Options: "latte", "frappe", "macchiato", "mocha"

		-- Add any other Catppuccin options you want here:
		transparent_background = false,
		term_colors = true,
		integrations = {
			cmp = true,
			gitsigns = true,
			nvimtree = true,
			telescope = true,
			notify = true,
			mini = true,
			-- Enable more integrations as needed
		},
		-- ... etc., refer to catppuccin/nvim documentation for all options
	},
}
