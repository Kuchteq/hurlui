return {
	'nvim-telescope/telescope.nvim',
	tag = '0.1.1',
	dependencies = { 'nvim-lua/plenary.nvim' },
	keys = { 'æ', 'ŋ', '’' },
	config = function()
		local builtin = require('telescope.builtin')
		vim.keymap.set('n', 'æ', builtin.find_files, {})
		vim.keymap.set('n', 'ŋ', builtin.live_grep, {})
		vim.keymap.set('n', '’', builtin.resume, {})
		vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
		vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
		vim.keymap.set('n', 'gr', require('telescope.builtin').lsp_references, {})
		require('telescope').setup {
			defaults = {
				mappings = {
					i = {
						["<C-j>"] = "move_selection_next",
						["<C-k>"] = "move_selection_previous",
						["<C-p>"] = "cycle_history_prev",
						["<C-n>"] = "cycle_history_next",
						["ŋ"] = "close",
						["æ"] = "close"
					}
				}
			} }
	end
}
