return {
  {
    "rcarriga/nvim-notify",
    lazy = false,
    priority = 1000,
    config = function()
      local notify = require("notify")
      local plugin = "My Awesome Plugin"

      -- function to compute dynamic dims
      local function get_dims()
        local cols = vim.o.columns
        local lines = vim.o.lines
        -- let's say max width = 40% of width, max height = 20% of height
        return math.floor(cols * 0.4), math.floor(lines * 0.2)
      end

      -- initial setup
      local w, h = get_dims()
      notify.setup({
        stages = "static",
        render = "minimal",
        timeout = 2000,
        max_width = w,
        max_height = h,
        top_down = false,
      })

      -- re-setup on window resize
      vim.api.nvim_create_autocmd("VimResized", {
        callback = function()
          local w2, h2 = get_dims()
          notify.setup({
            stages = "fade",
            render = "compact",
            timeout = 2000,
            max_width = w2,
            max_height = h2,
            top_down = false,
          })
        end,
      })

      -- override vim.notify globally:
      vim.notify = function(msg, level, opts)
        opts = opts or {}
        opts = vim.tbl_extend("force", {
          position = "bottom_right",
          title = plugin,
        }, opts)
        return notify(msg, level, opts)
      end
    end,
  },
}
