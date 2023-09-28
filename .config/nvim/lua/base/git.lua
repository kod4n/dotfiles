return {
	{
		"tpope/vim-fugitive",
		cmd = { "Git", "GBrowse", "Gdiffsplit", "Gvdiffsplit" },
		dependencies = {
			"tpope/vim-rhubarb",
		},
		keys = {
			{ "<leader>gs", "<cmd>Git<cr>", desc = "Git Status" },
		},
	},
	{
		-- Adds git related signs to the gutter, as well as utilities for managing changes
		"lewis6991/gitsigns.nvim",
		opts = {
			-- See `:help gitsigns.txt`
			signs = {
				add = { text = "│" },
				change = { text = "│" },
				delete = { text = "_" },
				topdelete = { text = "‾" },
				changedelete = { text = "~" },
				untracked = { text = "┆" },
			},
			current_line_blame = true,
			current_line_blame_opts = {
				virt_text = true,
				virt_text_pos = "eol",
				delay = 1000,
				ignore_whitespace = false,
			},
			on_attach = function(bufnr)
				local gs = package.loaded.gitsigns

				local function map(mode, l, r, opts)
					opts = opts or {}
					opts.buffer = bufnr
					vim.keymap.set(mode, l, r, opts)
				end

				-- navigation
				map("n", "]c", function()
					if vim.wo.diff then
						return "]c"
					end
					vim.schedule(function()
						gs.next_hunk()
					end)
					return "<Ignore>"
				end, { expr = true, desc = "next git change" })
				map("n", "[c", function()
					if vim.wo.diff then
						return "[c"
					end
					vim.schedule(function()
						gs.prev_hunk()
					end)
					return "<Ignore>"
				end, { expr = true, desc = "prev git change" })

				map("n", "<leader>hs", gs.stage_hunk, { buffer = bufnr, desc = "[H]unk [S]tage" })
				map("n", "<leader>hr", gs.reset_hunk, { buffer = bufnr, desc = "[H]unk [R]eset" })
				map("v", "<leader>hs", function()
					gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
				end, { buffer = bufnr, desc = "[H]unk [S]tage selection" })
				map("v", "<leader>hr", function()
					gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
				end, { buffer = bufnr, desc = "[H]unk [R]eset selection" })
				map("n", "<leader>hS", gs.stage_buffer, { buffer = bufnr, desc = "[H]unk [S]tage ALL" })
				map("n", "<leader>hu", gs.undo_stage_hunk, { buffer = bufnr, desc = "[H]unk [U]ndo" })
				map("n", "<leader>hR", gs.reset_buffer, { buffer = bufnr, desc = "[H]unk [R]eset ALL" })
				map("n", "<leader>hp", gs.preview_hunk, { buffer = bufnr, desc = "[H]unk [P]review" })
				map("n", "<leader>td", gs.toggle_deleted, { buffer = bufnr, desc = "[T]oggle [D]eleted" })
			end,
		},
		config = function(_, opts)
			require("gitsigns").setup(opts)
		end,
	},
}
