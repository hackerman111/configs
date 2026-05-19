-- ~/.config/nvim/lua/plugins/ipynb.lua
--
-- Drop this file into a lazy.nvim/LazyVim plugin directory.
-- Goal: edit .ipynb as readable Markdown, run cells through Jupyter kernels,
-- keep outputs in the notebook, and render plots/images inside Neovim when possible.
--
-- External dependencies:
--   python -m pip install --user pynvim jupyter_client jupytext nbformat ipykernel pillow
-- Optional, but useful:
--   python -m pip install --user pnglatex cairosvg plotly kaleido pyperclip
--   # Linux/Arch: install ImageMagick; for non-Kitty terminals also install ueberzugpp.
--   # Then add a kernel if needed:
--   python -m ipykernel install --user --name python3 --display-name "Python 3"

local function has(cmd)
  return vim.fn.executable(cmd) == 1
end

local function notify(msg, level)
  vim.notify(msg, level or vim.log.levels.INFO, { title = "ipynb.nvim" })
end

local function contains(xs, x)
  if type(xs) ~= "table" then
    return false
  end
  for _, v in ipairs(xs) do
    if v == x then
      return true
    end
  end
  return false
end

local function basename(path)
  if not path or path == "" then
    return nil
  end
  return vim.fn.fnamemodify(path, ":t")
end

local function safe_json_file(path)
  local fd = io.open(path, "r")
  if not fd then
    return nil
  end
  local raw = fd:read("*a")
  fd:close()
  local ok, decoded = pcall(vim.json.decode, raw)
  if ok then
    return decoded
  end
  return nil
end

local function notebook_kernel(path)
  local nb = safe_json_file(path)
  local metadata = nb and nb.metadata or nil
  local kernelspec = metadata and metadata.kernelspec or nil
  return kernelspec and kernelspec.name or nil
end

local function env_kernel_candidate()
  return basename(vim.env.VIRTUAL_ENV) or basename(vim.env.CONDA_PREFIX)
end

local function command_arg(s)
  -- Kernel names are usually simple, but escaping keeps custom names usable.
  return vim.fn.escape(s, [[ \|"']])
end

local function image_provider()
  -- Override when needed:
  --   vim.g.ipynb_image_provider = "none" | "image.nvim" | "wezterm"
  if vim.g.ipynb_image_provider ~= nil then
    return vim.g.ipynb_image_provider
  end

  if vim.env.WEZTERM_PANE ~= nil then
    return "wezterm"
  end

  if vim.env.KITTY_WINDOW_ID ~= nil or vim.env.TERM == "xterm-kitty" or has("ueberzugpp") then
    return "image.nvim"
  end

  return "none"
end

local function molten_is_ready()
  local ok, status = pcall(require, "molten.status")
  return ok and status.initialized() == "Molten"
end

local function molten_update(name, value)
  if molten_is_ready() then
    pcall(vim.fn.MoltenUpdateOption, name, value)
  else
    vim.g["molten_" .. name] = value
  end
end

local function try_init_molten_for_ipynb(args)
  if vim.b[args.buf].ipynb_molten_init_done then
    return
  end
  vim.b[args.buf].ipynb_molten_init_done = true

  vim.schedule(function()
    if not vim.api.nvim_buf_is_valid(args.buf) then
      return
    end

    pcall(function()
      require("quarto").activate()
    end)

    local ok, kernels = pcall(vim.fn.MoltenAvailableKernels)
    if not ok then
      notify("Molten пока не загрузился. Выполни :Lazy sync и перезапусти Neovim.", vim.log.levels.WARN)
      return
    end

    local preferred = notebook_kernel(args.file)
    local fallback = env_kernel_candidate()
    local kernel = nil

    if preferred and contains(kernels, preferred) then
      kernel = preferred
    elseif fallback and contains(kernels, fallback) then
      kernel = fallback
    elseif contains(kernels, "python3") then
      kernel = "python3"
    end

    if not kernel then
      notify("Не найден Jupyter kernel для этого ноутбука. Проверь :MoltenInfo или создай kernel через ipykernel.", vim.log.levels.WARN)
      return
    end

    local init_ok = pcall(vim.cmd, "MoltenInit " .. command_arg(kernel))
    if not init_ok then
      notify("Не удалось запустить Molten kernel: " .. kernel, vim.log.levels.WARN)
      return
    end

    if vim.g.ipynb_import_outputs ~= false then
      vim.defer_fn(function()
        pcall(vim.cmd, "MoltenImportOutput")
      end, 250)
    end
  end)
end

local function setup_ipynb_commands()
  vim.api.nvim_create_user_command("IpyHealth", function()
    local checks = {}

    local function add(name, ok, hint)
      table.insert(checks, { name = name, ok = ok, hint = hint })
    end

    add("jupytext executable", has("jupytext"), "python -m pip install --user jupytext")
    add("jupyter executable", has("jupyter"), "python -m pip install --user jupyter_client ipykernel")
    add("python3 executable", has("python3"), "установи Python 3")

    if has("python3") then
      local code = "import pynvim, jupyter_client, nbformat"
      local result
      if vim.system then
        result = vim.system({ "python3", "-c", code }, { text = true }):wait()
        add("python modules: pynvim, jupyter_client, nbformat", result.code == 0, result.stderr)
      else
        vim.fn.system({ "python3", "-c", code })
        add("python modules: pynvim, jupyter_client, nbformat", vim.v.shell_error == 0, "python -m pip install --user pynvim jupyter_client nbformat")
      end
    end

    add("ImageMagick magick", has("magick"), "для image.nvim: установи ImageMagick")
    add("ueberzugpp or Kitty/WezTerm", has("ueberzugpp") or vim.env.KITTY_WINDOW_ID ~= nil or vim.env.WEZTERM_PANE ~= nil, "для inline-картинок вне Kitty/WezTerm: установи ueberzugpp")

    local lines = { "ipynb.nvim health:" }
    for _, c in ipairs(checks) do
      local mark = c.ok and "OK" or "MISS"
      local line = ("  [%s] %s"):format(mark, c.name)
      if not c.ok and c.hint and c.hint ~= "" then
        line = line .. " -> " .. vim.trim(c.hint)
      end
      table.insert(lines, line)
    end
    notify(table.concat(lines, "\n"), vim.log.levels.INFO)
  end, { desc = "Check notebook dependencies" })

  vim.api.nvim_create_user_command("IpyNew", function(opts)
    local path = opts.args
    if path == "" then
      notify("Usage: :IpyNew path/to/name.ipynb", vim.log.levels.ERROR)
      return
    end
    if not path:match("%.ipynb$") then
      path = path .. ".ipynb"
    end
    path = vim.fn.fnamemodify(path, ":p")
    vim.fn.mkdir(vim.fn.fnamemodify(path, ":h"), "p")
    if vim.fn.filereadable(path) == 1 then
      vim.cmd.edit(vim.fn.fnameescape(path))
      return
    end

    local notebook = {
      cells = {
        {
          cell_type = "markdown",
          metadata = {},
          source = { "# New notebook\n" },
        },
        {
          cell_type = "code",
          execution_count = vim.NIL,
          metadata = {},
          outputs = {},
          source = { "" },
        },
      },
      metadata = {
        kernelspec = {
          display_name = "Python 3",
          language = "python",
          name = "python3",
        },
        language_info = {
          name = "python",
          file_extension = ".py",
          mimetype = "text/x-python",
          nbconvert_exporter = "python",
          pygments_lexer = "ipython3",
          version = "3",
        },
      },
      nbformat = 4,
      nbformat_minor = 5,
    }

    local encoded = vim.json.encode(notebook)
    vim.fn.writefile(vim.split(encoded, "\n"), path)
    vim.cmd.edit(vim.fn.fnameescape(path))
  end, {
    nargs = 1,
    complete = "file",
    desc = "Create a new Python .ipynb notebook",
  })

  vim.api.nvim_create_user_command("IpyPairPercent", function()
    local file = vim.api.nvim_buf_get_name(0)
    if not file:match("%.ipynb$") then
      notify("Открой .ipynb, затем выполни :IpyPairPercent", vim.log.levels.ERROR)
      return
    end
    if not has("jupytext") then
      notify("Нужен jupytext: python -m pip install --user jupytext", vim.log.levels.ERROR)
      return
    end
    local out = vim.fn.system({ "jupytext", "--set-formats", "ipynb,py:percent", file })
    if vim.v.shell_error == 0 then
      notify("Ноутбук связан с py:percent. Выполни :IpySync после внешних изменений.")
    else
      notify(out, vim.log.levels.ERROR)
    end
  end, { desc = "Pair current .ipynb with a py:percent script" })

  vim.api.nvim_create_user_command("IpySync", function()
    local file = vim.api.nvim_buf_get_name(0)
    if file == "" then
      notify("Нет файла для синхронизации", vim.log.levels.ERROR)
      return
    end
    if not has("jupytext") then
      notify("Нужен jupytext: python -m pip install --user jupytext", vim.log.levels.ERROR)
      return
    end
    local out = vim.fn.system({ "jupytext", "--sync", file })
    if vim.v.shell_error == 0 then
      notify("Jupytext sync завершён")
      vim.cmd.checktime()
    else
      notify(out, vim.log.levels.ERROR)
    end
  end, { desc = "Run jupytext --sync for current file" })
end

local function setup_ipynb_autocmds()
  local group = vim.api.nvim_create_augroup("PapaykaIpyNb", { clear = true })

  vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
    group = group,
    pattern = "*.ipynb",
    callback = function(args)
      vim.bo[args.buf].filetype = "markdown"
      vim.b[args.buf].quarto_is_ipynb = true
      try_init_molten_for_ipynb(args)
    end,
  })

  vim.api.nvim_create_autocmd("BufEnter", {
    group = group,
    pattern = { "*.ipynb", "*.qmd", "*.md" },
    callback = function(args)
      if args.file:find("%.otter%.") then
        return
      end
      molten_update("virt_text_output", true)
      molten_update("virt_lines_off_by_1", true)
      molten_update("auto_open_output", false)
      pcall(function()
        require("quarto").activate()
      end)
    end,
  })

  vim.api.nvim_create_autocmd("BufEnter", {
    group = group,
    pattern = "*.py",
    callback = function(args)
      if args.file:find("%.otter%.") then
        return
      end
      molten_update("virt_text_output", false)
      molten_update("virt_lines_off_by_1", false)
      molten_update("auto_open_output", true)
    end,
  })

  vim.api.nvim_create_autocmd("BufWritePost", {
    group = group,
    pattern = "*.ipynb",
    callback = function()
      if vim.g.ipynb_export_outputs == false then
        return
      end
      if molten_is_ready() then
        pcall(vim.cmd, "MoltenExportOutput!")
      end
    end,
  })

  vim.api.nvim_create_autocmd("FileType", {
    group = group,
    pattern = { "markdown", "quarto", "python" },
    callback = function(args)
      local opts = { buffer = args.buf, silent = true }
      local function map(mode, lhs, rhs, desc)
        opts.desc = desc
        vim.keymap.set(mode, lhs, rhs, opts)
      end

      map("n", "<localleader>mi", "<cmd>MoltenInit<cr>", "Molten: init kernel")
      map("n", "<localleader>mI", "<cmd>MoltenInfo<cr>", "Molten: info")
      map("n", "<localleader>mx", "<cmd>MoltenInterrupt<cr>", "Molten: interrupt")
      map("n", "<localleader>mr", "<cmd>MoltenRestart!<cr>", "Molten: restart and clear outputs")
      map("n", "<localleader>md", "<cmd>MoltenDelete<cr>", "Molten: delete current output")
      map("n", "<localleader>mD", "<cmd>MoltenDelete!<cr>", "Molten: delete all outputs")
      map("n", "<localleader>mo", "<cmd>noautocmd MoltenEnterOutput<cr>", "Molten: enter output")
      map("n", "<localleader>mh", "<cmd>MoltenHideOutput<cr>", "Molten: hide output")
      map("n", "<localleader>mb", "<cmd>MoltenOpenInBrowser<cr>", "Molten: open HTML in browser")
      map("n", "<localleader>my", "<cmd>MoltenYankOutput!<cr>", "Molten: yank output to clipboard")
      map("n", "<localleader>ms", "<cmd>MoltenSave<cr>", "Molten: save session outputs")
      map("n", "<localleader>ml", "<cmd>MoltenLoad<cr>", "Molten: load session outputs")

      local ok, runner = pcall(require, "quarto.runner")
      if ok then
        map("n", "<localleader>rc", runner.run_cell, "Notebook: run cell")
        map("n", "<localleader>ra", runner.run_above, "Notebook: run cells above")
        map("n", "<localleader>rA", runner.run_all, "Notebook: run all cells")
        map("n", "<localleader>rl", runner.run_line, "Notebook: run line")
        map("v", "<localleader>r", runner.run_range, "Notebook: run selection")
        map("n", "<localleader>rL", function()
          runner.run_all(true)
        end, "Notebook: run all languages")
      else
        map("n", "<localleader>rl", "<cmd>MoltenEvaluateLine<cr>", "Molten: run line")
        map("v", "<localleader>r", ":<C-u>MoltenEvaluateVisual<cr>gv", "Molten: run selection")
      end

      map("n", "<localleader>rr", "<cmd>MoltenReevaluateCell<cr>", "Notebook: re-run current cell")
      map("n", "]c", "<cmd>MoltenNext<cr>", "Notebook: next executed cell")
      map("n", "[c", "<cmd>MoltenPrev<cr>", "Notebook: previous executed cell")
    end,
  })
end

return {
  {
    "goerz/jupytext.nvim",
    version = "0.2.0",
    lazy = false,
    opts = {
      jupytext = "jupytext",
      format = "markdown",
      update = true,
      filetype = "markdown",
      autosync = true,
      handle_url_schemes = true,
    },
  },

  {
    "3rd/image.nvim",
    cond = function()
      return image_provider() == "image.nvim"
    end,
    build = false,
    opts = function()
      local backend = nil
      if vim.env.KITTY_WINDOW_ID ~= nil or vim.env.TERM == "xterm-kitty" or vim.env.WEZTERM_PANE ~= nil then
        backend = "kitty"
      elseif has("ueberzugpp") then
        backend = "ueberzug"
      end

      return {
        backend = backend,
        processor = "magick_cli",
        integrations = {
          markdown = { enabled = false },
          neorg = { enabled = false },
          html = { enabled = false },
          css = { enabled = false },
        },
        max_width_window_percentage = 70,
        max_height_window_percentage = 45,
        window_overlap_clear_enabled = true,
      }
    end,
  },

  {
    "willothy/wezterm.nvim",
    cond = function()
      return image_provider() == "wezterm"
    end,
    opts = {},
  },

  {
    "benlubas/molten-nvim",
    version = ">=1.9.0",
    build = ":UpdateRemotePlugins",
    lazy = false,
    dependencies = {
      "goerz/jupytext.nvim",
      "3rd/image.nvim",
      "willothy/wezterm.nvim",
    },
    init = function()
      vim.g.molten_auto_image_popup = false
      vim.g.molten_auto_init_behavior = "raise"
      vim.g.molten_auto_open_html_in_browser = false
      vim.g.molten_auto_open_output = false
      vim.g.molten_copy_output = false
      vim.g.molten_cover_empty_lines = true
      vim.g.molten_enter_output_behavior = "open_and_enter"
      vim.g.molten_image_provider = image_provider()
      vim.g.molten_image_location = "both"
      vim.g.molten_limit_output_chars = 200000
      vim.g.molten_output_crop_border = true
      vim.g.molten_output_show_exec_time = true
      vim.g.molten_output_show_more = true
      vim.g.molten_output_virt_lines = true
      vim.g.molten_output_win_border = { "", "━", "", "" }
      vim.g.molten_output_win_cover_gutter = false
      vim.g.molten_output_win_hide_on_leave = false
      vim.g.molten_output_win_max_height = 18
      vim.g.molten_output_win_max_width = 120
      vim.g.molten_output_win_style = "minimal"
      vim.g.molten_tick_rate = 180
      vim.g.molten_use_border_highlights = true
      vim.g.molten_virt_lines_off_by_1 = true
      vim.g.molten_virt_text_output = true
      vim.g.molten_virt_text_max_lines = 18
      vim.g.molten_virt_text_truncate = "bottom"
      vim.g.molten_wrap_output = true
      vim.g.molten_save_path = vim.fn.stdpath("data") .. "/molten"
    end,
    config = function()
      setup_ipynb_commands()
      setup_ipynb_autocmds()
    end,
  },

  {
    "quarto-dev/quarto-nvim",
    ft = { "quarto", "markdown", "ipynb" },
    dependencies = {
      "jmbuhr/otter.nvim",
      "nvim-treesitter/nvim-treesitter",
      "benlubas/molten-nvim",
    },
    opts = {
      lspFeatures = {
        enabled = true,
        languages = { "python", "r", "julia", "bash", "lua" },
        chunks = "all",
        diagnostics = {
          enabled = true,
          triggers = { "BufWritePost" },
        },
        completion = {
          enabled = true,
        },
      },
      keymap = {
        hover = "K",
        definition = "gd",
        rename = "<leader>rn",
        references = "gr",
        format = "<leader>gf",
      },
      codeRunner = {
        enabled = true,
        default_method = "molten",
      },
    },
  },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if opts.ensure_installed == "all" then
        return
      end
      opts.ensure_installed = opts.ensure_installed or {}
      local seen = {}
      for _, parser in ipairs(opts.ensure_installed) do
        seen[parser] = true
      end
      for _, parser in ipairs({
        "markdown",
        "markdown_inline",
        "python",
        "r",
        "julia",
        "bash",
        "lua",
        "yaml",
        "json",
      }) do
        if not seen[parser] then
          table.insert(opts.ensure_installed, parser)
        end
      end
    end,
  },

  {
    "lewis6991/gitsigns.nvim",
    optional = true,
    opts = function(_, opts)
      local old_on_attach = opts.on_attach
      opts.on_attach = function(bufnr)
        local name = vim.api.nvim_buf_get_name(bufnr)
        if name:match("%.ipynb$") then
          return false
        end
        if old_on_attach then
          return old_on_attach(bufnr)
        end
        return true
      end
    end,
  },
}
