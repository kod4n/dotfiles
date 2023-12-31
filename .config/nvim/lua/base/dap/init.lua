return {
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		opts = {
			defaults = {
				["<leader>d"] = { name = "+DAP" },
			},
		},
	},
	{
		"mfussenegger/nvim-dap",
		dependencies = {
			{ "rcarriga/nvim-dap-ui" },
			{ "theHamsta/nvim-dap-virtual-text" },
		},
		-- stylua: ignore
		keys = {
			{ "<leader>b", function() require("dap").toggle_breakpoint() end, desc = "Toggle Breakpoint", },
			{ "<leader>B", function() require("dap").set_breakpoint(vim.fn.input "[Condition] > ") end, desc = "Conditional Breakpoint", },
			{ "<F5>", function() require("dap").continue() end, desc = "Continue", },
			{ "<F10>", function() require("dap").step_over() end, desc = "Step Over", },
			{ "<F11>", function() require("dap").step_into() end, desc = "Step Into", },
			{ "<F12>", function() require("dap").step_back() end, desc = "Step Back", },
			-- { "<leader>dR", function() require("dap").run_to_cursor() end, desc = "Run to Cursor", },
			-- { "<leader>dd", function() require("dap").disconnect() end, desc = "Disconnect", },
			-- { "<leader>dg", function() require("dap").session() end, desc = "Get Session", },
			-- { "<leader>dp", function() require("dap").pause.toggle() end, desc = "Pause", },
			-- { "<leader>dq", function() require("dap").close() end, desc = "Quit", },
			-- { "<leader>dr", function() require("dap").repl.toggle() end, desc = "Toggle REPL", },
			-- { "<leader>ds", function() require("dap").continue() end, desc = "Start", },
			-- { "<leader>dx", function() require("dap").terminate() end, desc = "Terminate", },
			-- { "<leader>du", function() require("dap").step_out() end, desc = "Step Out", },
			-- { "<leader>dE", function() require("dapui").eval(vim.fn.input "[Expression] > ") end, desc = "Evaluate Input", },
			-- { "<leader>dU", function() require("dapui").toggle() end, desc = "Toggle UI", },
			-- { "<leader>de", function() require("dapui").eval() end, mode = {"n", "v"}, desc = "Evaluate", },
			-- { "<leader>dh", function() require("dap.ui.widgets").hover() end, desc = "Hover Variables", },
			-- { "<leader>dS", function() require("dap.ui.widgets").scopes() end, desc = "Scopes", },
		},
		config = function(plugin, opts)
			require("nvim-dap-virtual-text").setup({ commented = true })

			local dap, dapui = require("dap"), require("dapui")
			dapui.setup()

			dap.listeners.after.event_initialized["dapui_config"] = function()
				dapui.open()
			end
			dap.listeners.before.event_terminated["dapui_config"] = function()
				dapui.close()
			end
			dap.listeners.before.event_exited["dapui_config"] = function()
				dapui.close()
			end

			-- set up debugger
			for k, _ in pairs(opts.setup) do
				opts.setup[k](plugin, opts)
			end
		end,
	},
}
