-- Файл: snippets/tex.lua
-- Описание: Единая коллекция LaTeX-сниппетов для LuaSnip.
-- Совместимость: LuaSnip v2.* + blink.cmp (preset = "luasnip")
--
-- ИСПРАВЛЕНИЯ:
--   1. Формат возврата изменён на { snippets = {...}, autosnippets = {...} }
--      — это обязательный формат lua-loader, который blink.cmp понимает корректно.
--   2. Исправлена тень: `local s` внутри not_preceded_by_bs_or_letter
--      перекрывала `s = ls.snippet` из внешней области видимости.
--   3. Убраны дублированные сниппеты `sec` и `sbec`.
--   4. Добавлен in_mathzone(): греческие буквы и мат. операторы теперь
--      срабатывают только внутри математического окружения.

local ls    = require("luasnip")
local s     = ls.snippet
local sn    = ls.snippet_node
local i     = ls.insert_node
local t     = ls.text_node
local f     = ls.function_node
local d     = ls.dynamic_node
local rep   = require("luasnip.extras").rep
local conds = require("luasnip.extras.expand_conditions")

-- ──────────────────────────────────────────────────────────────
-- Утилиты
-- ──────────────────────────────────────────────────────────────

--- Возвращает true, если курсор находится в математическом окружении.
--- Приоритет: vimtex → treesitter → false.
local function in_mathzone()
    if vim.fn.exists("*vimtex#syntax#in_mathzone") == 1 then
        return vim.fn["vimtex#syntax#in_mathzone"]() == 1
    end
    local ok, node = pcall(vim.treesitter.get_node)
    if not ok or not node then return false end
    while node do
        local tp = node:type()
        if tp == "math_environment"
            or tp == "inline_formula"
            or tp == "displayed_equation"
        then
            return true
        end
        node = node:parent()
    end
    return false
end

--- Запрещает срабатывание, если перед триггером стоит '\' или буква.
--- Предотвращает повторное расширение \alpha → \alpha, \lambda и т.п.
local function not_preceded_by_bs_or_letter(trigger)
    return function(line_to_cursor)
        -- ИСПРАВЛЕНО: было `local s = ...`, теперь `local idx = ...`
        -- (тень над `s = ls.snippet` из внешней области видимости)
        local idx = line_to_cursor:find(trigger .. "%s*$")
        if not idx then return true end
        if idx == 1 then return true end
        local prev = line_to_cursor:sub(idx - 1, idx - 1)
        if prev == "\\" then return false end
        if prev:match("[%a]") or prev:match("[А-Яа-яЁё]") then return false end
        return true
    end
end

--- Создаёт autosnippet, который срабатывает только в мат. окружении.
--- Принимает те же аргументы, что и ls.snippet, но автоматически
--- добавляет `condition = in_mathzone` (или комбинирует с существующим).
local function ms(trig_opts, nodes, opts)
    opts = opts or {}
    local orig_cond = opts.condition
    if orig_cond then
        opts.condition = function(...) return in_mathzone() and orig_cond(...) end
    else
        opts.condition = in_mathzone
    end
    if type(trig_opts) == "string" then
        trig_opts = { trig = trig_opts, name = trig_opts, snippetType = "autosnippet" }
    elseif trig_opts.snippetType == nil then
        trig_opts.snippetType = "autosnippet"
    end
    return s(trig_opts, nodes, opts)
end

--- Создаёт сниппет вида \command{<1>}<0>.
local function wrapped_command_snippet(trig, command, name, opts)
    opts = opts or {}
    return s({
        trig        = trig,
        name        = name or command,
        dscr        = opts.dscr or ("\\" .. command .. "{}"),
        wordTrig    = opts.wordTrig ~= false,
        snippetType = opts.snippetType or "autosnippet",
    }, {
        t("\\" .. command .. "{"),
        i(1, opts.placeholder or "text"),
        t("}"),
        i(0),
    })
end

--- Конвертирует Markdown-список из выделения в LaTeX \item.
local function md_list_to_latex(_, snip)
    local lines = snip.env.TM_SELECTED_TEXT
    if not lines or #lines == 0 then return { "\\item " } end
    local result = {}
    for _, line in ipairs(lines) do
        table.insert(result, (line:gsub("^%s*%d+%.%s+", "\\item ")))
    end
    return result
end

-- ──────────────────────────────────────────────────────────────
-- Коллекция сниппетов
-- ──────────────────────────────────────────────────────────────
local snippets = {}

---------------------------------------------------
-- 1. Структура документа
---------------------------------------------------
snippets.structure = {
    s({
        trig        = "Preamble",
        name        = "Aesthetic Preamble",
        dscr        = "Полная преамбула LuaLaTeX с tcolorbox-теоремами",
        snippetType = "autosnippet",
    }, {
        t({
            "%!TEX program = lualatex",
            "\\documentclass[12pt,a4paper]{article}",
            "",
            "% ——————————————————————————————————————————————————",
            "%   ЧАСТЬ 1: ЯДРО СИСТЕМЫ",
            "% ——————————————————————————————————————————————————",
            "\\usepackage{polyglossia}",
            "\\setdefaultlanguage{russian}",
            "\\setotherlanguage{english}",
            "\\usepackage{fontspec}",
            "\\defaultfontfeatures{Ligatures=TeX, Scale=MatchLowercase}",
            "\\usepackage{unicode-math}",
            "\\setmainfont{Fira Sans}",
            "\\setmathfont{Latin Modern Math}",
            "\\usepackage{microtype}",
            "\\usepackage{subfiles}",
            "",
            "% ——————————————————————————————————————————————————",
            "%   ЧАСТЬ 2: МАКЕТ",
            "% ——————————————————————————————————————————————————",
            "\\usepackage[a4paper, left=2.5cm, right=2.5cm, top=2.5cm, bottom=3cm]{geometry}",
            "\\usepackage{setspace}",
            "\\setstretch{1.2}",
            "\\usepackage{parskip}",
            "",
            "% ——————————————————————————————————————————————————",
            "%   ЧАСТЬ 3: ЦВЕТА И БЛОКИ",
            "% ——————————————————————————————————————————————————",
            "\\usepackage[table, dvipsnames, svgnames]{xcolor}",
            "\\usepackage{fontawesome5}",
            "\\definecolor{DeepTeal}{HTML}{003153}",
            "\\definecolor{SoftSand}{HTML}{f8f9fa}",
            "\\definecolor{WarmGray}{HTML}{607d8b}",
            "\\definecolor{OffBlack}{HTML}{212121}",
            "\\usepackage[most]{tcolorbox}",
            "\\tcbuselibrary{breakable, skins, theorems}",
            "\\tcbset{",
            "    enhanced, breakable, arc=0pt, boxrule=0pt,",
            "    left=4mm, right=4mm, top=3mm, bottom=3mm, boxsep=1mm,",
            "    colback=SoftSand, colframe=white,",
            "    borderline west={1.5pt}{0pt}{DeepTeal},",
            "    fonttitle=\\bfseries\\color{DeepTeal},",
            "    attach boxed title to top left={xshift=5mm, yshift=-2mm},",
            "    boxed title style={boxrule=0pt, colback=SoftSand, arc=0pt},",
            "}",
            "\\newtcbtheorem[auto counter, number within=section]{theorem}{\\faBookReader\\quad Теорема}{}{th}",
            "\\newtcbtheorem[auto counter, number within=section]{lemma}{\\faLightbulb\\quad Лемма}{}{lem}",
            "\\newtcbtheorem[auto counter, number within=section]{definition}{\\faFileAlt\\quad Определение}{}{def}",
            "\\newtcbtheorem[auto counter, number within=section]{remark}{\\faPenFancy\\quad Замечание}{}{rem}",
            "\\newtcbtheorem[auto counter, number within=section]{example}{\\faVial\\quad Пример}{}{ex}",
            "\\newtcolorbox[auto counter]{problembox}[1][]{",
            "    title={\\faTasks\\quad Задача \\thetcbcounter},",
            "    before upper={\\addcontentsline{toc}{section}{Задача \\thetcbcounter}},",
            "    #1",
            "}",
            "\\newtcolorbox{solutionbox}[1][]{",
            "    title={\\faCheckSquare\\quad Решение},",
            "    borderline west={1.5pt}{0pt}{WarmGray},",
            "    before upper={\\addcontentsline{toc}{subsection}{Решение}},",
            "    #1",
            "}",
            "\\newtcolorbox{proofbox}[1][]{",
            "    title={\\faCubes\\quad Доказательство},",
            "    colback=white, colframe=white,",
            "    borderline west={1.5pt}{0pt}{WarmGray}, #1",
            "}",
            "",
            "% ——————————————————————————————————————————————————",
            "%   ЧАСТЬ 4: ДОПОЛНЕНИЯ",
            "% ——————————————————————————————————————————————————",
            "\\usepackage{graphicx, wrapfig, float}",
            "\\usepackage{booktabs}",
            "\\usepackage{enumitem}",
            "\\setlist{topsep=3pt, itemsep=2pt, parsep=0pt, label=—}",
            "\\usepackage{hyperref}",
            "\\hypersetup{",
            "  colorlinks=true, linkcolor=DeepTeal, urlcolor=WarmGray, citecolor=DeepTeal,",
            "  pdftitle={",
        }),
        i(1, "Название документа"),
        t({ "}," }),
        t({ "  pdfauthor={" }),
        i(2, "Автор"),
        t({ "}," }),
        t({ "  pdfsubject={" }),
        i(3, "Тема"),
        t({
            "},",
            "  hidelinks",
            "}",
            "\\usepackage[russian]{cleveref}",
            "\\usepackage{fancyhdr}",
            "\\pagestyle{fancy}",
            "\\fancyhf{}",
            "\\fancyhead[R]{\\small\\itshape ",
        }),
        rep(2),
        t({ " }", "\\fancyhead[L]{\\small\\itshape " }),
        rep(1),
        t({
            "}",
            "\\fancyfoot[C]{\\color{WarmGray}\\thepage}",
            "\\renewcommand{\\headrulewidth}{0.4pt}",
            "\\renewcommand{\\headrule}{\\color{WarmGray}\\hrulefill}",
            "",
            "% ——————————————————————————————————————————————————",
            "%   ЧАСТЬ 5: ПОЛЬЗОВАТЕЛЬСКИЕ КОМАНДЫ",
            "% ——————————————————————————————————————————————————",
            "\\newcommand{\\incfig}[2][1]{%",
            "  \\def\\svgwidth{#1\\columnwidth}%",
            "  \\import{./figures/}{#2.pdf_tex}%",
            "}",
            "\\begin{document}",
            "\\begin{titlepage}",
            "  \\centering",
            "  {\\scshape\\Huge ",
        }),
        rep(1),
        t({ " }", "  {\\scshape\\Huge " }),
        rep(2),
        t({
            " }",
            "  \\vfill",
            "  {\\color{WarmGray}\\today}",
            "\\end{titlepage}",
            "\\tableofcontents",
            "\\newpage",
            "",
        }),
        i(0),
        t({ "", "\\end{document}" }),
    }),

    -- Секции (каждый триггер только один раз)
    s({ trig = "sec", name = "Section", snippetType = "autosnippet" },
        { t("\\section{"), i(1, "Заголовок"), t("}") },
        { condition = conds.line_begin }),
    s({ trig = "Sec", name = "Section*", snippetType = "autosnippet" },
        { t("\\section*{"), i(1, "Заголовок"), t("}") },
        { condition = conds.line_begin }),
    s({ trig = "sbec", name = "Subsection", snippetType = "autosnippet" },
        { t("\\subsection{"), i(1, "Подраздел"), t("}") },
        { condition = conds.line_begin }),
    s({ trig = "ssbec", name = "Subsubsection", snippetType = "autosnippet" },
        { t("\\subsubsection{"), i(1, "Подподраздел"), t("}") },
        { condition = conds.line_begin }),
    s({ trig = "Par", name = "Paragraph*", snippetType = "autosnippet" },
        { t("\\paragraph*{"), i(1, "Абзац"), t("}") },
        { condition = conds.line_begin }),
    s({ trig = "parg", name = "Paragraph", snippetType = "autosnippet" },
        { t("\\paragraph{"), i(1, "Абзац"), t("}") },
        { condition = conds.line_begin }),
}

---------------------------------------------------
-- 2. Математический анализ  (только в мат. окружении)
---------------------------------------------------
snippets.analysis = {
    ms({ trig = "sum", name = "Sum", wordTrig = true }, {
        t("\\sum_{"), i(1, "i"), t("="), i(2, "0"), t("}^{"), i(3, "\\infty"), t("} "), i(0),
    }),
    ms({ trig = "prod", name = "Product", wordTrig = true }, {
        t("\\prod_{"), i(1, "i"), t("="), i(2, "1"), t("}^{"), i(3, "n"), t("} "), i(0),
    }),
    ms({ trig = "lim", name = "Limit", wordTrig = true }, {
        t("\\lim_{"), i(1, "x"), t(" \\to "), i(2, "0"), t("} "), i(0),
    }),
    ms({ trig = "int", name = "Integral", wordTrig = true }, {
        t("\\int "), i(1, "f(x)"), t(" \\,\\mathrm{d}"), i(2, "x"),
    }),
    ms({ trig = "dint", name = "Definite Integral", priority = 300 }, {
        t("\\int_{"), i(1, "-\\infty"), t("}^{"), i(2, "\\infty"),
        t("} "), i(3, "f(x)"), t(" \\,\\mathrm{d}"), i(4, "x"), t(" "), i(0),
    }),
    ms({ trig = "iint", name = "Double Integral" }, {
        t("\\iint_{"), i(1, "D"), t("} "), i(2, "f"),
        t(" \\,\\mathrm{d}"), i(3, "x"), t("\\,\\mathrm{d}"), i(4, "y"), t(" "), i(0),
    }),
    ms({ trig = "oint", name = "Contour Integral" }, {
        t("\\oint_{"), i(1, "C"), t("} "), i(2, "f"), t(" \\,\\mathrm{d}"), i(3, "z"),
    }),
    ms({ trig = "leb", name = "Lebesgue Integral" }, {
        t("\\int_{"), i(1, "X"), t("} "), i(2, "f"), t(" \\,\\mathrm{d}\\mu"), i(0),
    }),
    ms({ trig = "der", name = "Partial Derivative" }, {
        t("\\frac{\\partial "), i(1, "f"), t("}{\\partial "), i(2, "x"), t("}"), i(0),
    }),
    ms({ trig = "ddt", name = "d/dt Total Derivative" }, {
        t("\\frac{\\mathrm{d}"), i(1, "f"), t("}{\\mathrm{d}"), i(2, "t"), t("}"), i(0),
    }),
    ms({ trig = "taylor", name = "Taylor Series" }, {
        t("\\sum_{"), i(1, "k"), t("=0}^{\\infty} "),
        i(2, "c_k"), t("(x - a)^{"), rep(1), t("} "), i(0),
    }),
    ms({ trig = "inf", name = "Infimum", wordTrig = true }, {
        t("\\inf\\left\\{"), i(1, "S"), t("\\right\\}"), i(0),
    }),
    ms({ trig = "sup", name = "Supremum", wordTrig = true }, {
        t("\\sup\\left\\{"), i(1, "S"), t("\\right\\}"), i(0),
    }),
    ms({ trig = "nab", name = "Nabla" }, t("\\nabla ")),
    ms({ trig = "grad", name = "Gradient" }, { t("\\nabla "), i(1, "f") }),
    ms({ trig = "Lap", name = "Laplacian", wordTrig = true }, t("\\Delta ")),
    ms({ trig = "oo", name = "o-small", wordTrig = true }, t("o")),
    ms({ trig = "OO", name = "O-big", wordTrig = true }, t("O")),
}

---------------------------------------------------
-- 3. Линейная алгебра  (только в мат. окружении)
---------------------------------------------------
snippets.linear_algebra = {
    ms({ trig = "det", name = "Determinant", wordTrig = true }, {
        t("\\det\\left("), i(1, "A"), t("\\right)"), i(0),
    }),
    ms({ trig = "ov", name = "Vector Arrow", wordTrig = true }, {
        t("\\overrightarrow{"), i(1, "v"), t("}"), i(0),
    }),
    ms({ trig = "rk", name = "Rank", wordTrig = true }, {
        t("\\operatorname{rk}\\left("), i(1, "A"), t("\\right)"),
    }),
    ms({ trig = "dim", name = "Dimension", wordTrig = true }, {
        t("\\dim\\left("), i(1, "V"), t("\\right)"),
    }),
    ms({ trig = "Ker", name = "Kernel", wordTrig = true }, t("\\ker")),
    ms({ trig = "Im", name = "Image", wordTrig = true }, t("\\operatorname{Im}")),
    ms({ trig = "tr", name = "Trace", wordTrig = true }, t("\\operatorname{tr}")),
    ms({ trig = "Span", name = "Span", wordTrig = true }, {
        t("\\operatorname{Span}\\left\\{"), i(1), t("\\right\\}"),
    }),
    ms({ trig = "Hom", name = "Hom", wordTrig = true }, {
        t("\\operatorname{Hom}("), i(1, "V"), t(", "), i(2, "W"), t(")"),
    }),
    ms({ trig = "End", name = "End", wordTrig = true }, {
        t("\\operatorname{End}("), i(1, "V"), t(")"),
    }),
    ms({ trig = "Rad", name = "Rad", wordTrig = true }, t("\\operatorname{Rad}")),
    ms({ trig = "ort", name = "Ort", wordTrig = true }, {
        t("\\operatorname{ort}_{"), i(1, "v"), t("}{"), i(2, "u"), t("}"),
    }),
    ms({ trig = "opl", name = "Direct Sum", wordTrig = true }, t("\\oplus ")),
    ms({ trig = "tens", name = "Tensor Product" }, t("\\otimes ")),
    ms({ trig = "<<", name = "Inner Product" }, {
        t("\\left\\langle "), i(1, "u, v"), t(" \\right\\rangle"),
    }),
    ms({ trig = "tp", name = "Transpose" }, t("^{\\top}")),
    ms({ trig = "inv", name = "Inverse" }, t("^{-1}")),
    ms({ trig = "adj", name = "Adjoint / Conjugate" }, t("^{*}")),
    ms({ trig = "cvec", name = "Column Vector" }, {
        t("\\begin{pmatrix} "), i(1, "x"),
        t("_1 \\\\ \\vdots \\\\ "), rep(1), t("_{"), i(2, "n"), t(" \\end{pmatrix}"),
    }),
    -- Матрицы не требуют мат. окружения — они вставляются внутрь него
    s({ trig = "pmat", name = "pmatrix" }, {
        t({ "\\begin{pmatrix}", "\t" }), i(1, "..."), t({ "", "\\end{pmatrix} " }), i(0),
    }),
    s({ trig = "bmat", name = "bmatrix" }, {
        t({ "\\begin{bmatrix}", "\t" }), i(1, "..."), t({ "", "\\end{bmatrix} " }), i(0),
    }),
    s({ trig = "vmat", name = "vmatrix" }, {
        t({ "\\begin{vmatrix}", "\t" }), i(1, "..."), t({ "", "\\end{vmatrix} " }), i(0),
    }),
}

---------------------------------------------------
-- 4. Логика и теория множеств  (только в мат. окружении)
---------------------------------------------------
snippets.logic_and_sets = {
    ms({ trig = ";imp", name = "Implies", wordTrig = true }, t("\\implies")),
    ms({ trig = ";and", name = "Logical AND", wordTrig = true }, t("\\land")),
    ms({ trig = ";or", name = "Logical OR", wordTrig = true }, t("\\lor")),
    ms({ trig = ";net", name = "Logical NOT", wordTrig = true }, t("\\neg")),
    ms({ trig = ";eq", name = "Equivalence", wordTrig = true }, t("\\equiv")),
    ms({ trig = "fal", name = "For All", wordTrig = true }, {
        t("\\forall "), i(1, "x"), t(" \\colon "), i(0),
    }),
    ms({ trig = "exs", name = "Exists", wordTrig = true }, {
        t("\\exists "), i(1, "x"), t(" \\colon "), i(0),
    }),
    ms({ trig = "EXS", name = "Exists Unique", wordTrig = true }, {
        t("\\exists! "), i(1, "x"), t(" \\colon "), i(0),
    }),
    ms({ trig = "Uu", name = "Union" }, t("\\cup ")),
    ms({ trig = "Aa", name = "Intersection" }, t("\\cap ")),
    ms({ trig = "bigcup", name = "Big Union" }, {
        t("\\bigcup_{"), i(1, "i=1"), t("}^{"), i(2, "n"), t("} "),
    }),
    ms({ trig = "bigcap", name = "Big Intersection" }, {
        t("\\bigcap_{"), i(1, "i=1"), t("}^{"), i(2, "n"), t("} "),
    }),
    ms({ trig = "vkl", name = "Subset", wordTrig = true }, { t("\\subset "), i(0) }),
    ms({ trig = "subs", name = "Subseteq", wordTrig = true }, t("\\subseteq ")),
    ms({ trig = "inn", name = "In" }, t("\\in ")),
    ms({ trig = "notin", name = "Not In" }, t("\\notin ")),
    ms({ trig = "cc", name = "Empty Set", wordTrig = true }, t("\\emptyset")),
    ms({ trig = "cupdot", name = "Disjoint Union", wordTrig = true }, t("\\sqcup ")),
    ms({ trig = [[\\\]], name = "Set Minus" }, t("\\setminus")),
}

---------------------------------------------------
-- 5. Общие математические символы
---------------------------------------------------
snippets.general_math = {
    -- Мат. окружения (создают зону — условие не нужно)
    s({ trig = "uh", name = "Inline Math $...$", wordTrig = true, snippetType = "autosnippet" },
        { t("$"), i(1), t("$") }),
    s({ trig = "mk", name = "Inline Math \\(...\\)", wordTrig = true, snippetType = "autosnippet" },
        { t("\\( "), i(1, "x"), t(" \\)"), i(0) }),
    s({ trig = "dm", name = "Display Math \\[...\\]", wordTrig = true },
        { t({ "\\[", "\t" }), i(1), t({ "", "\\]" }), i(0) }),

    -- Степени / индексы
    ms({ trig = "sr", name = "^2", wordTrig = false }, t("^{2}")),
    ms({ trig = "cb", name = "^3", wordTrig = false }, t("^{3}")),
    ms({ trig = "ye", name = "Superscript", wordTrig = false }, { t("^{"), i(1), t("}") }),
    ms({ trig = "ft", name = "Subscript", wordTrig = false }, { t("_{"), i(1), t("}") }),

    -- Корни и дроби
    ms({ trig = "sq", name = "Square Root", wordTrig = true }, { t("\\sqrt{"), i(1), t("}"), i(0) }),
    ms({ trig = "snq", name = "Nth Root", wordTrig = true }, { t("\\sqrt["), i(1, "n"), t("]{"), i(2), t("}"), i(0) }),
    ms({ trig = "fr", name = "Fraction" }, { t("\\frac{"), i(1), t("}{"), i(2), t("}"), i(0) }),

    -- Дробь из слова перед /  (e.g. "a2/" → "\frac{a2}{}")
    s({
        trig        = "([^%s]+)/",
        name        = "Word Fraction",
        regTrig     = true,
        snippetType = "autosnippet",
        priority    = 1001,
    }, d(1, function(_, parent)
        -- ИСПРАВЛЕНО: parent.captures вместо parent.snippet.captures
        local num = parent.captures[1]
        if num:match(":") then return sn(nil, { t(num .. "/") }) end
        return sn(nil, { t("\\frac{" .. num .. "}{"), i(1), t("}") })
    end), { condition = in_mathzone })
    ,

    -- Дробь из выражения в скобках: "(a+b)/" → "\frac{a+b}{}"
    s({
        trig        = ".*%)/",
        name        = "() Fraction",
        wordTrig    = true,
        regTrig     = true,
        priority    = 1000,
        snippetType = "autosnippet",
    }, d(1, function(_, parent)
        -- ИСПРАВЛЕНО: parent.trigger вместо parent.snippet.trigger
        local stripped = parent.trigger:sub(1, -2)
        local depth, idx = 0, #stripped
        while idx >= 1 do
            local c = stripped:sub(idx, idx)
            if c == ")" then
                depth = depth + 1
            elseif c == "(" then
                depth = depth - 1
            end
            if depth == 0 then break end
            idx = idx - 1
        end
        if depth ~= 0 then
            return sn(nil, { t(stripped .. "\\frac{}{}"), i(1), i(0) })
        end
        return sn(nil, {
            t(stripped:sub(1, idx - 1) .. "\\frac{" .. stripped:sub(idx + 1) .. "}{"),
            i(1), t("}"), i(0),
        })
    end), { condition = in_mathzone }),


    -- Абс. значение, норма, ceil, floor
    ms({ trig = "abs", name = "Absolute Value" }, { t("\\left| "), i(1), t(" \\right|"), i(0) }),
    ms({ trig = "norm", name = "Norm", wordTrig = true }, { t("\\left\\| "), i(1), t(" \\right\\|"), i(0) }),
    ms({ trig = "ceil", name = "Ceiling" }, { t("\\left\\lceil "), i(1), t(" \\right\\rceil"), i(0) }),
    ms({ trig = "floor", name = "Floor" }, { t("\\left\\lfloor "), i(1), t(" \\right\\rfloor"), i(0) }),

    -- Числовые множества
    ms({ trig = "Rr", name = "Reals", wordTrig = true }, t("\\mathbb{R}")),
    ms({ trig = "Cc", name = "Complex", wordTrig = true }, t("\\mathbb{C}")),
    ms({ trig = "Nn", name = "Naturals", wordTrig = true }, t("\\mathbb{N}")),
    ms({ trig = "Zz", name = "Integers", wordTrig = true }, t("\\mathbb{Z}")),
    ms({ trig = "Qq", name = "Rationals", wordTrig = true }, t("\\mathbb{Q}")),
    ms({ trig = "Ff", name = "Field", wordTrig = true }, t("\\mathbb{F}")),
    ms({ trig = "Ee", name = "Euclid", wordTrig = true }, t("\\mathbb{E}")),
    ms({ trig = "Dd", name = "Domain", wordTrig = true }, t("\\mathbb{D}")),
    ms({ trig = "Vv", name = "Vect. Sp.", wordTrig = true }, t("\\mathbb{V}")),
    ms({ trig = "Kk", name = "Scalar Field", wordTrig = true }, t("\\mathbb{K}")),
    ms({ trig = "AF", name = "Affine Sp.", wordTrig = true }, t("\\mathbb{A}")),
    ms({ trig = "PP", name = "Probability", wordTrig = true }, t("\\mathbb{P}")),

    -- Теория вероятностей / статистика (ML)
    ms({ trig = "EEE", name = "Expected Value", wordTrig = true }, {
        t("\\mathbb{E}\\left["), i(1, "X"), t("\\right]"), i(0),
    }),
    ms({ trig = "Var", name = "Variance", wordTrig = true }, {
        t("\\operatorname{Var}\\left["), i(1, "X"), t("\\right]"),
    }),
    ms({ trig = "Cov", name = "Covariance", wordTrig = true }, {
        t("\\operatorname{Cov}\\left("), i(1, "X"), t(", "), i(2, "Y"), t("\\right)"),
    }),
    ms({ trig = "prb", name = "P(event)" }, {
        t("\\mathbb{P}\\left("), i(1), t("\\right)"), i(0),
    }),
    ms({ trig = "ind", name = "Indicator 1_{}" }, {
        t("\\mathbf{1}_{\\{"), i(1), t("\\}}"),
    }),

    -- Сравнения
    ms({ trig = "!=", name = "Not Equal" }, t("\\neq ")),
    ms({ trig = ">=", name = "Geq", wordTrig = true }, t("\\geq ")),
    ms({ trig = "<=", name = "Leq", wordTrig = true }, t("\\leq ")),
    ms({ trig = "approx", name = "Approx", wordTrig = true }, t("\\approx ")),
    ms({ trig = "sim", name = "Sim", wordTrig = true }, t("\\sim ")),
    ms({ trig = "cong", name = "Congruent", wordTrig = true }, t("\\cong ")),
    ms({ trig = "propt", name = "Propto", wordTrig = true }, t("\\propto ")),
    ms({ trig = "perp", name = "Perp", wordTrig = true }, t("\\perp ")),
    ms({ trig = "para", name = "Parallel", wordTrig = true }, t("\\parallel ")),

    -- Арифметика
    ms({ trig = "xx", name = "Times" }, t("\\times ")),
    ms({ trig = "**", name = "Cdot" }, t("\\cdot ")),
    ms({ trig = "PM", name = "Plus-minus" }, t("\\pm ")),
    ms({ trig = "MP", name = "Minus-plus" }, t("\\mp ")),

    -- Стрелки
    ms({ trig = "=>", name = "Implies" }, t("\\implies")),
    ms({ trig = "->", name = "To", priority = 100 }, t("\\to ")),
    ms({ trig = "-->", name = "Long To", priority = 200 }, t("\\longrightarrow ")),
    ms({ trig = "!>", name = "Mapsto" }, t("\\mapsto ")),
    ms({ trig = "siff", name = "Iff", priority = 100 }, t("\\iff")),
    ms({ trig = "lr", name = "Leftrightarrow" }, t("\\leftrightarrow")),
    ms({ trig = "ra", name = "Rightarrow" }, t("\\Rightarrow")),
    ms({ trig = "ras", name = "Squiggly →", wordTrig = true }, t("\\rightsquigarrow")),

    -- Разное
    ms({ trig = "...", name = "Ldots", priority = 100 }, t("\\ldots")),
    ms({ trig = "+.", name = "+ldots+" }, t("+ \\ldots + ")),
    ms({ trig = ",.", name = ",ldots," }, t(", \\ldots, ")),
    ms({ trig = ";in", name = "Infinity" }, t("\\infty")),
    ms({ trig = "par", name = "∂ subscript", wordTrig = true }, {
        t("\\partial_{"), i(1), t("}"), i(0),
    }),
    ms({ trig = "spec", name = "Spec", wordTrig = true }, t("\\operatorname{Spec}")),
    ms({ trig = "hbar", name = "ℏ" }, t("\\hbar")),
    ms({ trig = "ell", name = "ℓ" }, t("\\ell")),
    ms({ trig = "dag", name = "†" }, t("^{\\dagger}")),
    ms({ trig = "mod", name = "pmod", wordTrig = true }, { t("\\pmod{"), i(1), t("}"), i(0) }),
}

---------------------------------------------------
-- 6. Текстовые элементы и форматирование
---------------------------------------------------
snippets.text_and_formatting = {
    s({ trig = "BoT", name = "Bold Text", wordTrig = true, snippetType = "autosnippet" },
        { t("\\textbf{"), i(1, "text"), t("} "), i(0) }),
    s({ trig = "IoT", name = "Italic Text", wordTrig = true, snippetType = "autosnippet" },
        { t("\\textit{"), i(1, "text"), t("} "), i(0) }),
    s({ trig = "tt", name = "Text in Math", wordTrig = true, snippetType = "autosnippet" },
        { t("\\text{"), i(1, "text"), t("} "), i(0) }),
    s({ trig = "rm", name = "Math Roman", wordTrig = true, snippetType = "autosnippet" },
        { t("\\mathrm{"), i(1, "text"), t("} "), i(0) }),
    s({ trig = "cl", name = "Math Cal", wordTrig = true, snippetType = "autosnippet" },
        { t("\\mathcal{"), i(1, "text"), t("} "), i(0) }),
    s({ trig = "rbb", name = "Math bb", wordTrig = true, snippetType = "autosnippet" },
        { t("\\mathbb{"), i(1, "text"), t("} "), i(0) }),
    wrapped_command_snippet("opn", "operatorname", "Operator Name", { placeholder = "name" }),
    wrapped_command_snippet("mbb", "mathbb", "Math Blackboard", { placeholder = "A" }),
    wrapped_command_snippet("mcal", "mathcal", "Math Calligraphic", { placeholder = "A" }),
    wrapped_command_snippet("mscr", "mathscr", "Math Script", { placeholder = "A" }),
    wrapped_command_snippet("mfr", "mathfrak", "Math Fraktur", { placeholder = "g" }),
    wrapped_command_snippet("msf", "mathsf", "Math Sans", { placeholder = "X" }),
    wrapped_command_snippet("mbf", "mathbf", "Math Bold", { placeholder = "x" }),
    wrapped_command_snippet("mrm", "mathrm", "Math Roman", { placeholder = "d" }),
    wrapped_command_snippet("mtt", "mathtt", "Math Typewriter", { placeholder = "code" }),
}

---------------------------------------------------
-- 7. Среды и блоки
---------------------------------------------------
snippets.environments = {
    s({ trig = "beg", name = "Begin/End" }, {
        t("\\begin{"), i(1, "env"), t({ "}", "\t" }),
        i(0), t({ "", "\\end{" }), rep(1), t("}"),
    }, { condition = conds.line_begin }),

    s({ trig = "enum", name = "Enumerate" }, {
        t({ "\\begin{enumerate}", "\t\\item " }), i(0), t({ "", "\\end{enumerate}" }),
    }, { condition = conds.line_begin }),

    s({ trig = "item", name = "Itemize" }, {
        t({ "\\begin{itemize}", "\t\\item " }), i(0), t({ "", "\\end{itemize}" }),
    }, { condition = conds.line_begin }),

    s({ trig = "case", name = "Cases" }, {
        t({ "\\begin{cases}", "\t" }),
        i(1, "f(x) & x > 0 \\\\"), t({ "", "\t" }), i(0),
        t({ "", "\\end{cases}" }),
    }),

    s({ trig = "ali", name = "Align*" }, {
        t({ "\\begin{align*}", "\t" }), i(1), t({ " &= \\\\", "\t" }), i(0), t({ "", "\\end{align*}" }),
    }, { condition = conds.line_begin }),

    s({ trig = "alin", name = "Align (numbered)" }, {
        t({ "\\begin{align}", "\t" }), i(1), t({ " &= \\\\", "\t" }), i(0), t({ "", "\\end{align}" }),
    }, { condition = conds.line_begin }),

    -- split: уравнение с выравниванием внутри equation
    s({ trig = "split", name = "Split Equation" }, {
        t({ "\\begin{equation}", "\\begin{split}", "\t" }),
        i(1), t({ " &= \\\\", "\t" }), i(0),
        t({ "", "\\end{split}", "\\end{equation}" }),
    }, { condition = conds.line_begin }),

    s({ trig = "gath", name = "Gather*" }, {
        t({ "\\begin{gather*}", "\t" }), i(0), t({ "", "\\end{gather*}" }),
    }, { condition = conds.line_begin }),

    -- tcolorbox-теоремы
    s({ trig = "theor", name = "Theorem + Proof" }, {
        t("\\begin{theorem}{"), i(1, "Название"), t({ "}{}", "" }),
        i(2, "Утверждение"), t({ "", "\\end{theorem}", "", "\\begin{proofbox}", "" }),
        i(3, "Доказательство"), t({ "", "\\end{proofbox}" }),
    }, { condition = conds.line_begin }),

    s({ trig = "def", name = "Definition Block" }, {
        t("\\begin{definition}{"), i(1, "Название"), t({ "}{}", "" }),
        i(2, "Содержание"), t({ "", "\\end{definition}" }),
    }, { condition = conds.line_begin }),

    s({ trig = "exam", name = "Example Block" }, {
        t("\\begin{example}{"), i(1, "Название"), t({ "}{}", "" }),
        i(2, "Содержание"), t({ "", "\\end{example}" }),
    }, { condition = conds.line_begin }),

    s({ trig = "lem", name = "Lemma Block" }, {
        t("\\begin{lemma}{"), i(1, "Название"), t({ "}{}", "" }),
        i(2, "Содержание"), t({ "", "\\end{lemma}" }),
    }, { condition = conds.line_begin }),

    s({ trig = "rem", name = "Remark Block" }, {
        t("\\begin{remark}{"), i(1, "Название"), t({ "}{}", "" }),
        i(2, "Содержание"), t({ "", "\\end{remark}" }),
    }, { condition = conds.line_begin }),

    s({ trig = "task", name = "Task + Solution" }, {
        t({ "\\begin{problembox}", "" }), i(1, "Условие"),
        t({ "", "\\end{problembox}", "", "\\begin{solutionbox}", "" }),
        i(2, "Решение"), t({ "", "\\end{solutionbox}" }),
    }, { condition = conds.line_begin }),

    -- Figure / Table
    s({ trig = "fig", name = "Figure" }, {
        t({ "\\begin{figure}[htbp]", "\t\\centering", "\t\\includegraphics[width=" }),
        i(1, "0.8"), t("\\linewidth]{"), i(2, "filename"), t({ "}", "\t\\caption{" }),
        i(3, "Подпись"), t({ "}", "\t\\label{fig:" }), i(4, "label"), t({ "}", "\\end{figure}" }),
    }, { condition = conds.line_begin }),

    s({ trig = "tbl", name = "Table" }, {
        t({ "\\begin{table}[htbp]", "\t\\centering", "\t\\caption{" }),
        i(1, "Подпись"), t({ "}", "\t\\label{tab:" }), i(2, "label"),
        t({ "}", "\t\\begin{tabular}{" }), i(3, "lll"),
        t({ "}", "\t\t\\toprule", "\t\t" }), i(4, "Кол1 & Кол2 & Кол3 \\\\"),
        t({ "", "\t\t\\midrule", "\t\t" }), i(0),
        t({ "", "\t\t\\bottomrule", "\t\\end{tabular}", "\\end{table}" }),
    }, { condition = conds.line_begin }),

    s({ trig = "m2e", name = "MD List → Enumerate" }, {
        t({ "\\begin{enumerate}", "" }), f(md_list_to_latex, {}), t({ "", "\\end{enumerate}" }),
    }),
}

---------------------------------------------------
-- 8. Греческие буквы  (только в мат. окружении)
---------------------------------------------------
snippets.greek_letters = {
    ms({ trig = "@a", name = "alpha" }, t("\\alpha")),
    ms({ trig = "@b", name = "beta" }, t("\\beta")),
    ms({ trig = "@g", name = "gamma" }, t("\\gamma")),
    ms({ trig = "@G", name = "Gamma" }, t("\\Gamma")),
    ms({ trig = "@d", name = "delta" }, t("\\delta")),
    ms({ trig = "@D", name = "Delta" }, t("\\Delta")),
    ms({ trig = "@ep", name = "varepsilon" }, t("\\varepsilon")),
    ms({ trig = "@z", name = "zeta" }, t("\\zeta")),
    ms({ trig = "@et", name = "eta" }, t("\\eta")),
    ms({ trig = "@th", name = "theta" }, t("\\theta")),
    ms({ trig = "@Th", name = "Theta" }, t("\\Theta")),
    ms({ trig = "@i", name = "iota" }, t("\\iota")),
    ms({ trig = "@k", name = "kappa" }, t("\\kappa")),
    ms({ trig = "@l", name = "lambda" }, t("\\lambda")),
    ms({ trig = "@L", name = "Lambda" }, t("\\Lambda")),
    ms({ trig = "@m", name = "mu" }, t("\\mu")),
    ms({ trig = "@n", name = "nu" }, t("\\nu")),
    ms({ trig = "@x", name = "xi" }, t("\\xi")),
    ms({ trig = "@X", name = "Xi" }, t("\\Xi")),
    ms({ trig = "@s", name = "sigma" }, t("\\sigma")),
    ms({ trig = "@S", name = "Sigma" }, t("\\Sigma")),
    ms({ trig = "@ta", name = "tau" }, t("\\tau")),
    ms({ trig = "@u", name = "upsilon" }, t("\\upsilon")),
    ms({ trig = "@o", name = "omega" }, t("\\omega")),
    ms({ trig = "@O", name = "Omega" }, t("\\Omega")),
    ms({ trig = "@r", name = "rho" }, t("\\rho")),
    ms({ trig = "@p", name = "varphi" }, t("\\varphi")),
    ms({ trig = "@P", name = "Phi" }, t("\\Phi")),
    ms({ trig = "@c", name = "chi" }, t("\\chi")),
    ms({ trig = "@ps", name = "psi" }, t("\\psi")),
    ms({ trig = "@Ps", name = "Psi" }, t("\\Psi")),

    -- Триггеры с дополнительной защитой от \keyword
    ms({ trig = "pi", name = "uppi" }, t("\\uppi"),
        { condition = not_preceded_by_bs_or_letter("pi") }),
    ms({ trig = "phi", name = "varphi" }, t("\\varphi"),
        { condition = not_preceded_by_bs_or_letter("phi") }),
    ms({ trig = "psi", name = "psi" }, t("\\psi"),
        { condition = not_preceded_by_bs_or_letter("psi") }),
    ms({ trig = "Al", name = "σ-algebra ℱ" }, t("\\mathscr{F}"),
        { condition = not_preceded_by_bs_or_letter("Al") }),
}

---------------------------------------------------
-- 9. Скобки и разделители  (только в мат. окружении)
---------------------------------------------------
snippets.delimiters = {
    ms({ trig = "kk", name = "Parentheses", wordTrig = true }, {
        t("\\left( "), i(1), t(" \\right)"), i(0),
    }),
    ms({ trig = "{{", name = "Set Braces", wordTrig = true }, {
        t("\\left\\{ "), i(1), t(" \\right\\}"), i(0),
    }),
    ms({ trig = "lr|", name = "left|right|" }, {
        t("\\left| "), i(1), t(" \\right|"), i(0),
    }),
    ms({ trig = "[[", name = "left[right]" }, {
        t("\\left[ "), i(1), t(" \\right]"), i(0),
    }),
    ms({ trig = "<<", name = "left< right>" }, {
        t("\\left\\langle "), i(1), t(" \\right\\rangle"), i(0),
    }),
    s({ trig = "bcase", name = "Bracket Case System" }, {
        t({ "\\left[", "\t\\begin{gathered}", "\t\t" }),
        i(1, "x \\le y \\\\ \\\\ x < y"),
        t({ "", "\t\\end{gathered}", "\\right." }),
        i(0),
    }),
}

---------------------------------------------------
-- 10. Постфиксы и автовекторы
---------------------------------------------------
snippets.postfix_and_auto = (function()
    local result = {}

    local function generate_postfix_snippets(triggers)
        local list = {}
        for _, tw in ipairs(triggers) do
            local tw_cap = tw
            table.insert(list, s({
                name        = "Postfix: \\" .. tw_cap,
                trig        = "(" .. tw_cap .. ")%s*",
                regTrig     = true,
                wordTrig    = false,
                priority    = 200,
                snippetType = "autosnippet",
            }, {
                f(function(_, snip) return "\\" .. snip.captures[1] end, {}),
            }, {
                condition = function(...)
                    return in_mathzone() and not_preceded_by_bs_or_letter(tw_cap)(...)
                end,
            }))
        end
        return list
    end

    local func_triggers = {
        "sin", "cos", "tan", "csc", "sec", "cot",
        "ln", "log", "exp",
        "arcsin", "arccos", "arctan", "arcsec", "arccot",
        "sinh", "cosh", "tanh",
    }
    local greek_triggers = {
        "alpha", "beta", "gamma", "delta", "epsilon", "zeta", "eta", "theta",
        "iota", "kappa", "lambda", "mu", "nu", "xi", "pi", "rho", "sigma",
        "tau", "phi", "chi", "psi", "omega",
        "Alpha", "Beta", "Gamma", "Delta", "Epsilon", "Zeta", "Eta", "Theta",
        "Iota", "Kappa", "Lambda", "Mu", "Nu", "Xi", "Pi", "Rho", "Sigma",
        "Tau", "Phi", "Chi", "Psi", "Omega",
        "varepsilon", "varphi", "varrho", "vartheta",
    }

    vim.list_extend(result, generate_postfix_snippets(func_triggers))
    vim.list_extend(result, generate_postfix_snippets(greek_triggers))

    -- Автовекторы: a., a,. → \vec{a}
    local auto_vec_pats = {
        "([%a][%a])(%.,)", "([%a][%a])(,%.)",
        "([%a])(%.,)", "([%a])(,%.)",
    }
    for _, pat in ipairs(auto_vec_pats) do
        table.insert(result, s({
            trig        = pat,
            name        = "Auto Vector",
            regTrig     = true,
            snippetType = "autosnippet",
        }, {
            f(function(_, snip) return string.format("\\vec{%s} ", snip.captures[1]) end, {}),
        }, { condition = in_mathzone }))
    end

    return result
end)()

---------------------------------------------------
-- 11. Разное  (в основном только в мат. окружении)
---------------------------------------------------
snippets.misc = {
    -- Автоиндексы: x2 → x_{2}, x_23 → x_{23}
    ms({ trig = "([%a])(%d)", name = "Auto Subscript", regTrig = true },
        f(function(_, snip) return string.format("%s_%s", snip.captures[1], snip.captures[2]) end, {})),

    -- 2. Для греческих букв и команд LaTeX (например, \theta1 -> \theta_{1})
    ms({ trig = "(\\%a+)(%d)", name = "Auto Subscript (LaTeX)", regTrig = true },
        f(function(_, snip) return string.format("%s_%s", snip.captures[1], snip.captures[2]) end, {})),

    -- 3. Для одиночных символов с двумя цифрами (например, a_12 -> a_{12})
    ms({ trig = "([%a])_(%d%d)", name = "Auto Subscript 2", regTrig = true },
        f(function(_, snip) return string.format("%s_{%s}", snip.captures[1], snip.captures[2]) end, {})),

    -- 4. Для LaTeX-команд с двумя цифрами (например, \theta_12 -> \theta_{12})
    ms({ trig = "(\\%a+)_(%d%d)", name = "Auto Subscript 2 (LaTeX)", regTrig = true },
        f(function(_, snip) return string.format("%s_{%s}", snip.captures[1], snip.captures[2]) end, {})),

    -- Инлайн-декораторы
    ms({ trig = "hat", name = "hat", priority = 10 }, { t("\\hat{"), i(1), t("}"), i(0) }),
    ms({ trig = "bar", name = "overline", priority = 10 }, { t("\\overline{"), i(1), t("}"), i(0) }),
    ms({ trig = "til", name = "tilde", priority = 10 }, { t("\\tilde{"), i(1), t("}"), i(0) }),
    ms({ trig = "wt", name = "widetilde" }, { t("\\widetilde{"), i(1), t("}"), i(0) }),
    ms({ trig = "wh", name = "widehat" }, { t("\\widehat{"), i(1), t("}"), i(0) }),
    ms({ trig = "vv", name = "vec" }, { t("\\vec{"), i(1), t("}"), i(0) }),
    ms({ trig = "dot", name = "dot", priority = 10 }, { t("\\dot{"), i(1), t("}"), i(0) }),
    ms({ trig = "ddot", name = "ddot" }, { t("\\ddot{"), i(1), t("}"), i(0) }),

    -- Постфиксные декораторы: xbar → \overline{x}
    ms({ trig = "(%a+)bar", regTrig = true, name = "bar word", priority = 100 },
        f(function(_, snip) return string.format("\\overline{%s}", snip.captures[1]) end, {})),
    ms({ trig = "(%a+)hat", regTrig = true, name = "hat word", priority = 100 },
        f(function(_, snip) return string.format("\\hat{%s}", snip.captures[1]) end, {})),
    ms({ trig = "(%a+)til", regTrig = true, name = "tilde word", priority = 100 },
        f(function(_, snip) return string.format("\\tilde{%s}", snip.captures[1]) end, {})),
    ms({ trig = "(%a+)und", regTrig = true, name = "underline", priority = 100 },
        f(function(_, snip) return string.format("\\underline{%s}", snip.captures[1]) end, {})),
    ms({ trig = "(%a)dot", regTrig = true, name = "dot", priority = 100 },
        f(function(_, snip) return string.format("\\dot{%s}", snip.captures[1]) end, {})),
    ms({ trig = "(%a+)ora", regTrig = true, name = "overrightarrow", priority = 100 },
        f(function(_, snip) return string.format("\\overrightarrow{%s}", snip.captures[1]) end, {})),
    ms({ trig = "(%a+)ola", regTrig = true, name = "overleftarrow", priority = 100 },
        f(function(_, snip) return string.format("\\overleftarrow{%s}", snip.captures[1]) end, {})),
}

---------------------------------------------------
-- 12. Курсовая: Алгебры Ли + TDA
---------------------------------------------------
snippets.coursework = {
    -- Операторы алгебры Ли
    s({ trig = "pd", dscr = "Partial derivative operator" }, {
        t("\\frac{\\partial}{\\partial "), i(1, "z"), t("_{"), i(2, "n"), t("}}"),
    }),
    s({ trig = "vf", dscr = "Vector field term" }, {
        i(1, "f"), t(" \\frac{\\partial}{\\partial "), i(2, "z"), t("}"),
    }),
    s({ trig = "Der", dscr = "Derivation algebra" }, { t("\\operatorname{Der}") }),
    s({ trig = "Aut", dscr = "Automorphism group" }, { t("\\operatorname{Aut}") }),
    s({ trig = "Lie", dscr = "Lie algebra \\mathfrak{g}" }, {
        t("\\mathfrak{"), i(1, "g"), t("}"),
    }),
    s({ trig = "lb", dscr = "Lie bracket [u, v]" }, {
        t("["), i(1, "u"), t(", "), i(2, "v"), t("]"), i(0),
    }),
    s({ trig = "ad", dscr = "ad_x^n operator", snippetType = "autosnippet" }, {
        t("\\operatorname{ad}_{"), i(1, "x"), t("}^{"), i(2), t("}"), i(0),
    }),
    s({ trig = "poly", dscr = "Polynomial ring K[z_1,...,z_n]" }, {
        t("\\mathbb{K}["), i(1, "z"), t("_1, \\dots, "), rep(1), t("_{"), i(2, "n"), t("}]"),
    }),
    s({ trig = "genA", dscr = "Andrist generators {U,V,W}" }, { t("\\{U, V, W\\}") }),
    s({ trig = "genB", dscr = "Beldiev generators {U,V}" }, { t("\\{U, V\\}") }),
    s({ trig = "Wn", dscr = "Witt algebra W_n" }, {
        t("W_{"), i(1, "n"), t("}"),
    }),

    -- Топологический анализ данных (TDA)
    s({ trig = "PH", dscr = "Persistent Homology PH_k" }, {
        t("\\mathrm{PH}_{"), i(1, "k"), t("}"),
    }),
    s({ trig = "dgm", dscr = "Persistence diagram Dgm_k" }, {
        t("\\mathrm{Dgm}_{"), i(1, "k"), t("}"),
    }),
    s({ trig = "RTD", dscr = "RTD(X,Y) distance" }, {
        t("\\mathrm{RTD}("), i(1, "X"), t(", "), i(2, "Y"), t(")"),
    }),
    s({ trig = "betti", dscr = "Betti number \\beta_k" }, {
        t("\\beta_{"), i(1, "k"), t("}"),
    }),

    -- Нумерованные уравнения
    s({ trig = "eq", dscr = "Equation + Label" }, {
        t("\\begin{equation}\\label{eq:"), i(1, "label"), t({ "}", "\t" }),
        i(2, "content"), t({ "", "\\end{equation}" }),
    }, { condition = conds.line_begin }),

    s({ trig = "al", dscr = "Align + Label" }, {
        t("\\begin{align}\\label{eq:"), i(1, "label"), t({ "}", "\t" }),
        i(2), t({ " &= \\\\", "\t" }), i(0), t({ "", "\\end{align}" }),
    }, { condition = conds.line_begin }),

    s({ trig = "rf", dscr = "\\label{}" }, { t("\\label{"), i(1, "label"), t("}") }),
    s({ trig = "cr", dscr = "\\cref{}" }, { t("\\cref{"), i(1, "label"), t("}") }),
}

-- ──────────────────────────────────────────────────────────────
-- Сборка и возврат
-- ──────────────────────────────────────────────────────────────
-- ИСПРАВЛЕНО: lua-loader LuaSnip и blink.cmp (preset = "luasnip") требуют
-- формат { snippets = {...}, autosnippets = {...} }.
-- Плоский список `return get_all_snippets()` приводит к тому, что
-- autosnippets не регистрируются отдельно и blink не видит их корректно.
--
local function build_snippet_table()
    local regular, auto = {}, {}
    for _, cat in pairs(snippets) do
        for _, snip in ipairs(cat) do
            if snip.snippetType == "autosnippet" then
                table.insert(auto, snip)
            else
                table.insert(regular, snip)
            end
        end
    end
    -- Возвращаем два массива, как того требует LuaSnip
    return regular, auto
end

-- Распаковываем массивы при возврате
return build_snippet_table()
