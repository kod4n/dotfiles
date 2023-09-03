return {
	-- undotree
	{
		"mbbill/undotree",
		keys = {
			{ "<leader>u", "<cmd>UndotreeToggle<cr>", desc = "Toggle Undotree" },
		},
	},

	-- tabs and shiftwidth
	"tpope/vim-sleuth",

	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		opts = {
			defaults = {
				["<leader>g"] = { name = "+Git" },
			},
		},
	},
}
