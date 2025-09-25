-- ~/.config/nvim/lua/plugins/marks.lua
return {
  "chentoast/marks.nvim",
  event = "VeryLazy",
  dependencies = { "nvim-telescope/telescope.nvim" },
  config = function()
    require("marks").setup({
      -- Ваши настройки marks.nvim
    })
  end,
}
