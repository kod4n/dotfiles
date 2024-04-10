vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking text",
	group = vim.api.nvim_create_augroup("kod4n-highlight-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})

return {
	pde = {
		lua = true,
		cpp = true,
		go = true,
		typescript = true,
		python = true,
		rust = true,
		terraform = true,
	},
}
