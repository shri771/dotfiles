return {
    {
        'stevearc/oil.nvim',
        opts = {},
        config = function()
            require("oil").setup({
                columns = {
                    "icon",
                    -- "permissions",
                    -- "size",
                    -- "mtime",
                },
                -- Buffer-local options to use for oil buffers
                buf_options = {
                    buflisted = false,
                    bufhidden = "hide",
                },
                -- Window-local options to use for oil buffers
                win_options = {
                    wrap = false,
                    signcolumn = "no",
                    cursorcolumn = false,
                    foldcolumn = "0",
                    spell = false,
                    list = false,
                    conceallevel = 3,
                    concealcursor = "nvic",
                },
                -- Send deleted files to the trash instead of permanently deleting them (:help oil-trash)
                delete_to_trash = true,
                -- Skip the confirmation popup for simple operations (:help oil.skip_confirm_for_simple_edits)
                skip_confirm_for_simple_edits = true,
                -- Selecting a new/moved/renamed file or directory will prompt you to save changes first
                prompt_save_on_select_new_entry = true,
                -- Oil will automatically delete hidden buffers after this delay
                cleanup_delay_ms = 2000,
                lsp_file_methods = {
                    enabled = true,
                    timeout_ms = 1000,
                    autosave_changes = false,
                },
                -- Constrain the cursor to the editable parts of the oil buffer
                constrain_cursor = "editable",
                -- Set to true to watch the filesystem for changes and reload oil
                watch_for_changes = false,
                -- Keymaps in oil buffer
                keymaps = {
                    ["g?"] = { "actions.show_help", mode = "n" },
                    ["<CR>"] = "actions.select",
                    ["<C-s>"] = { "actions.select", opts = { vertical = true } },
                    ["<C-h>"] = { "actions.select", opts = { horizontal = true } },
                    ["<C-t>"] = { "actions.select", opts = { tab = true } },
                    ["<C-p>"] = "actions.preview",
                    ["<C-c>"] = { "actions.close", mode = "n" },
                    ["<C-l>"] = "actions.refresh",
                    ["-"] = { "actions.parent", mode = "n" },
                    ["_"] = { "actions.open_cwd", mode = "n" },
                    ["`"] = { "actions.cd", mode = "n" },
                    ["~"] = { "actions.cd", opts = { scope = "tab" }, mode = "n" },
                    ["gs"] = { "actions.change_sort", mode = "n" },
                    ["gx"] = "actions.open_external",
                    ["g."] = { "actions.toggle_hidden", mode = "n" },
                    ["g\\"] = { "actions.toggle_trash", mode = "n" },
                },
                use_default_keymaps = true,
                view_options = {
                    show_hidden = false,
                    is_hidden_file = function(name, bufnr)
                        local m = name:match("^%.")
                        return m ~= nil
                    end,
                    is_always_hidden = function(name, bufnr)
                        return false
                    end,
                    natural_order = "fast",
                    case_insensitive = false,
                    sort = {
                        { "type", "asc" },
                        { "name", "asc" },
                    },
                    highlight_filename = function(entry, is_hidden, is_link_target, is_link_orphan)
                        return nil
                    end,
                },
                extra_scp_args = {},
                git = {
                    add = function(path)
                        return false
                    end,
                    mv = function(src_path, dest_path)
                        return false
                    end,
                    rm = function(path)
                        return false
                    end,
                },
                -- Configuration for the floating window in oil.open_float
                float = {
                    padding = 2,
                    max_width = 0.6,  -- 60% of the total width
                    max_height = 0.6, -- 60% of the total height
                    border = "rounded",
                    win_options = {
                        winblend = 0,
                    },
                    get_win_title = nil,
                    preview_split = "auto",
                    override = function(conf)
                        return conf
                    end,
                },
                preview_win = {
                    update_on_cursor_moved = true,
                    preview_method = "fast_scratch",
                    disable_preview = function(filename)
                        return false
                    end,
                    win_options = {},
                },
                confirmation = {
                    max_width = 0.9,
                    min_width = { 40, 0.4 },
                    width = nil,
                    max_height = 0.9,
                    min_height = { 5, 0.1 },
                    height = nil,
                    border = "rounded",
                    win_options = {
                        winblend = 0,
                    },
                },
                progress = {
                    max_width = 0.9,
                    min_width = { 40, 0.4 },
                    width = nil,
                    max_height = { 10, 0.9 },
                    min_height = { 5, 0.1 },
                    height = nil,
                    border = "rounded",
                    minimized_border = "none",
                    win_options = {
                        winblend = 0,
                    },
                },
                ssh = {
                    border = "rounded",
                },
                keymaps_help = {
                    border = "rounded",
                },
            })

            -- Keymap to open oil.nvim in a floating window
            vim.keymap.set("n", "-", function()
                require("oil").open_float()
            end, { desc = "Open Oil in floating window" })
        end,
        dependencies = { { "echasnovski/mini.icons", opts = {} } },
        lazy = false,
    }
}
