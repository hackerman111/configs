local M = {}

local function modules()
  return vim.g.nvim_treesitter_legacy_modules or {}
end

function M.get_module(name)
  return modules()[name] or {}
end

function M.is_enabled(name, lang, bufnr)
  local module = M.get_module(name)
  if module.enable == false then
    return false
  end

  local disable = module.disable
  if type(disable) == "function" then
    return not disable(lang, bufnr)
  end

  if type(disable) == "table" and vim.tbl_contains(disable, lang) then
    return false
  end

  return true
end

return M
