return {
  {
    "jkeresman01/spring-initializr.nvim",
    cmd = { "SpringInitializr", "SpringGenerateProject" },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-telescope/telescope.nvim",
    },
    keys = {
      { "<leader>si", "<CMD>SpringInitializr<CR>", desc = "Spring Initializr UI" },
      { "<leader>sb", "<CMD>SpringGenerateProject<CR>", desc = "Spring generate project" },
    },
    config = function()
      require("spring-initializr").setup()
    end,
  },
}
