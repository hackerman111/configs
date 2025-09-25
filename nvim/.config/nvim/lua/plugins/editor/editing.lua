-- ~/.config/nvim/lua/plugins/editing.lua
-- Плагины для редактирования и навигации

return {
  -- Основные утилиты
  { "tpope/vim-fugitive" },
  { "numToStr/Comment.nvim", opts = {} },
  { "christoomey/vim-tmux-navigator",
    config = function()
      vim.g.tmux_navigator_no_mappings = 1
    end
  },
  { "lyokha/vim-xkbswitch",
  init = function()
    vim.g.XkbSwitchEnabled = 1
    vim.g.XkbSwitchIMappings = {'ru'}
  end
  },
  -- Улучшенная навигация
}

