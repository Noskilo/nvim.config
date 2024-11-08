-- telescope
vim.keymap.set("n", "<leader>fs", ":Telescope find_files<cr>")
vim.keymap.set("n", "<leader>fp", ":Telescope git_files<cr>")
vim.keymap.set("n", "<leader>fz", ":Telescope live_grep<cr>")
vim.keymap.set("n", "<leader>fo", ":Telescope oldfiles<cr>")

-- tree
vim.keymap.set("n", "<leader>e", ":NvimTreeFindFileToggle<cr>")


-- markdown preview
vim.keymap.set("n", "<leader>mp", ":MarkdownPreviewToggle<cr>")


-- nvim-comment
vim.keymap.set({ "n", "v" }, "<C-_>", ":CommentToggle<cr>")

-- format code
vim.keymap.set("n", "<leader>fmd", vim.lsp.buf.format)

-- auto-session
vim.keymap.set("n", "<leader>ls", require("auto-session.session-lens").search_session, { noremap = true })

-- tyescript
vim.keymap.set("n", "<leader>to", ":OrganizeImports<cr>")
