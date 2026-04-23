local M = {}

function M.run()
  local ok_utils, utils = pcall(require, "telescope.previewers.utils")
  assert(ok_utils, "expected telescope.previewers.utils to load")

  local bufnr = vim.api.nvim_create_buf(false, true)
  vim.bo[bufnr].filetype = "lua"

  local ok_highlighter, err = pcall(utils.ts_highlighter, bufnr, "lua")
  assert(ok_highlighter, err)

  print("telescope_treesitter_compat: ok")
end

return M
