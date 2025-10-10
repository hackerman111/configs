-- Файл: snippets.lua

-- Описание: Единая коллекция LaTeX-сниппетов для LuaSnip.
-- Личным сниппетам отдается приоритет в случае конфликтов.

-- Подключение компонентов LuaSnip
local ls = require("luasnip")
local s = ls.snippet
local sn = ls.snippet_node
local i = ls.insert_node
local t = ls.text_node
local f = ls.function_node
local d = ls.dynamic_node
local rep = require("luasnip.extras").rep
local conds = require("luasnip.extras.expand_conditions")

-- Запрещает срабатывание, если перед триггером стоит '\' или буква (латиница/кириллица).
-- Это предотвращает повторное срабатывание на уже вставленных командах \alpha, \lambda, \uppi и т.д.
local function not_preceded_by_bs_or_letter(trigger)
	return function(line_to_cursor)
		-- Разрешаем хвостовые пробелы: ищем "<trigger><пробелы><конец строки>"
		local s = line_to_cursor:find(trigger .. "%s*$")
		if not s then
			return true
		end
		if s == 1 then
			return true
		end
		local prev = line_to_cursor:sub(s - 1, s - 1)
		-- Блокируем, если перед триггером: обратный слэш или буква (латиница/кириллица)
		if prev == "\\" then
			return false
		end
		if prev:match("[%a]") or prev:match("[А-Яа-яЁё]") then
			return false
		end
		return true
	end
end

-- Таблица с категориями сниппетов
local snippets = {}

---------------------------------------------------
-- Категория 1: Структура документа
---------------------------------------------------

snippets.structure = {
	s({
		trig = "Preamble",
		name = "Aesthetic Preamble Lvl 290",
		dscr = "A professional, beautiful, and highly aesthetic preamble.",
		snippetType = "autosnippet",
	}, {
		t({
			"\\documentclass[12pt,a4paper]{article}",
			"",
			"% ——————————————————————————————————————————————————",
			"%   ЧАСТЬ 1: ЯДРО СИСТЕМЫ (ДВИЖОК, ЯЗЫКИ, ШРИФТЫ)",
			"% ——————————————————————————————————————————————————",
			"",
			"% Требуется компилятор LuaLaTeX или XeLaTeX для поддержки современных шрифтов",
			"\\usepackage{polyglossia}",
			"\\setdefaultlanguage{russian}",
			"\\setotherlanguage{english}",
			"",
			"\\usepackage{fontspec}",
			"\\defaultfontfeatures{Ligatures=TeX, Scale=MatchLowercase}",
			"\\setmainfont{Libertinus Math Regular}",
			"",
			"\\usepackage{unicode-math}",
			"",
			"\\usepackage{microtype} % Улучшенная микро-типографика",
			"\\usepackage{subfiles}",
			"",
			"% ——————————————————————————————————————————————————",
			"%   ЧАСТЬ 2: МАКЕТ И ГЕОМЕТРИЯ СТРАНИЦЫ",
			"% ——————————————————————————————————————————————————",
			"",
			"\\usepackage[a4paper, left=2.5cm, right=2.5cm, top=2.5cm, bottom=3cm]{geometry}",
			"\\usepackage{setspace}",
			"\\setstretch{1.2} % Более воздушное межстрочное расстояние",
			"",
			"\\usepackage{parskip} % Современный интервал между абзацами вместо отступа",
			"",
			"% ——————————————————————————————————————————————————",
			"%   ЧАСТЬ 3: ЦВЕТОВАЯ ПАЛИТРА И СТИЛЬ БЛОКОВ",
			"% ——————————————————————————————————————————————————",
			"",
			"\\usepackage[table, dvipsnames, svgnames]{xcolor}",
			"\\usepackage{fontawesome5}",
			"",
			"% Утонченная академическая палитра",
			"definecolor{DeepTeal}{HTML}{003153}     % Акцент",
			"definecolor{SoftSand}{HTML}{f8f9fa}     % Фон блоков",
			"definecolor{WarmGray}{HTML}{607d8b}     % Детали",
			"definecolor{OffBlack}{HTML}{212121}     % Текст",
			"",
			"\\usepackage[most]{tcolorbox}",
			"\\tcbuselibrary{breakable, skins, theorems}",
			"",
			"% Единый минималистичный стиль для всех блоков",
			"\\tcbset{",
			"    enhanced, breakable, arc=0pt, boxrule=0pt,",
			"    left=4mm, right=4mm, top=3mm, bottom=3mm, boxsep=1mm,",
			"    colback=SoftSand, colframe=white,",
			"    borderline west={1.5pt}{0pt}{DeepTeal}, % Элегантная линия слева",
			"    fonttitle=\\bfseries\\color{DeepTeal},",
			"    attach boxed title to top left={xshift=5mm, yshift=-2mm},",
			"    boxed title style={boxrule=0pt, colback=SoftSand, arc=0pt},",
			"}",
			"",
			"% Определения для теорем и окружений с иконками",
			"\\newtcbtheorem[auto counter, number within=section]{theorem}{\\faBookReader\\quad Теорема}{}{th}",
			"\\newtcbtheorem[auto counter, number within=section]{lemma}{\\faLightbulb\\quad Лемма}{}{lem}",
			"\\newtcbtheorem[auto counter, number within=section]{definition}{\\faFileAlt\\quad Определение}{}{def}",
			"\\newtcbtheorem[auto counter, number within=section]{remark}{\\faPenFancy\\quad Замечание}{}{rem}",
			"\\newtcbtheorem[auto counter, number within=section]{example}{\\faVial\\quad Пример}{}{ex}",
			"",
			"\\newtcolorbox[auto counter]{problembox}[1][]{",
			"    title={\\faTasks\\quad Задача \\thetcbcounter},",
			"before upper={\\addcontentsline{toc}{section}{Задача \\thetcbcounter}}",
			"#1",
			"}",
			"\\newtcolorbox{solutionbox}[1][]{",
			"    title={\\faCheckSquare\\quad Решение},",
			"before upper={\\addcontentsline{toc}{subsection}{Задача \\thetcbcounter}}",
			"    borderline west={1.5pt}{0pt}{WarmGray}, #1",
			"}",
			"\\newtcolorbox{proofbox}[1][]{",
			"    title={\\faCubes\\quad Доказательство},",
			"    colback=white, colframe=white,",
			"    borderline west={1.5pt}{0pt}{WarmGray}, #1",
			"}",
			"",
			"% ——————————————————————————————————————————————————",
			"%   ЧАСТЬ 4: УЛУЧШЕНИЯ И ДОПОЛНЕНИЯ",
			"% ——————————————————————————————————————————————————",
			"",
			"% Графика, таблицы и списки",
			"\\usepackage{graphicx}",
			"\\usepackage{wrapfig}",
			"\\usepackage{float}",
			"\\usepackage{booktabs} % Профессиональные таблицы",
			"\\usepackage{enumitem}",
			"\\setlist{topsep=3pt, itemsep=2pt, parsep=0pt, label=—}",
			"",
			"% Гиперссылки и 'умные' ссылки",
			"\\usepackage{hyperref}",
			"\\hypersetup{",
			"  colorlinks=true, linkcolor=DeepTeal, urlcolor=WarmGray, citecolor=DeepTeal,",
			"  pdftitle={",
		}),
		i(1, "Название документа"),
		t("},"),
		t("  pdfauthor={"),
		i(2, "Автор"),
		t("},"),
		t({
			"  pdfsubject={",
		}),
		i(3, "Тема"),
		t({
			"},",
			"  hidelinks % Убираем рамки, оставляем только цвет",
			"}",
			"\\usepackage[russian]{cleveref} % Для умных ссылок \\cref{}",
			"",
			"% Элегантные колонтитулы",
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
			"%   ЧАСТЬ 5: ПОЛЬЗОВАТЕЛЬСКИЕ КОМАНДЫ И НАЧАЛО ДОКУМЕНТА",
			"% ——————————————————————————————————————————————————",
			"",
			"\\newcommand{\\incfig}[2][1]{%",
			"  \\def\\svgwidth{#1\\columnwidth}%",
			"  \\import{./figures/}{#2.pdf_tex}%",
			"}",
			"",
			"\\begin{document}",
			"",
			"\\begin{titlepage}",
			"  \\centering",
			"  {\\scshape\\Huge ",
		}),
		rep(3),
		t({
			"}",
			"  {\\scshape\\Huge ",
		}),
		rep(2),
		t({
			" ",
			"}",
			"  \\vfill",
			"  {\\color{WarmGray}\\today}",
			"\\end{titlepage}",
			"\\tableofcontents",
			"\\newpage",
		}),
		i(0),
		t({
			"",
			"\\end{document}",
		}),
	}),
	s(
		{ trig = "sec", name = "Section", dscr = "Create a new section", snippetType = "autosnippet" },
		{ t("\\section{"), i(1, "Заголовок раздела"), t("}") },
		{ condition = conds.line_begin }
	),

	-- Subsection + optional paragraph
	s({ trig = "sbec", name = "Subsection", dscr = "Create a new subsection" }, {
		t("\\subsection{"),
		i(1, "Заголовок подраздела"),
		t({ "}", "\\paragraph{\\textbf{" }),
		rep(1),
		t({ "}}", "" }),
		i(2, "Текст"),
	}, { condition = conds.line_begin }),

	-- Paragraph
	s(
		{ trig = "par", name = "Paragraph", dscr = "Create a new paragraph", snippetType = "autosnippet" },
		{ t("\\paragraph*{\\textbf{"), i(1, "Заголовок абзаца"), t("}}") },
		{ condition = conds.line_begin }
	),

	s(
		{ trig = "sec", name = "Section", dscr = "Create a new section", snippetType = "autosnippet" },
		{ t("\\section*{\\textbf{"), i(1, "Section Title"), t("}}") },
		{ condition = conds.line_begin }
	),
	s({
		trig = "sbec",
		name = "Subsection",
		dscr = "Create a new subsection",
	}, {
		t("\\subsection{ \\textbf{"),
		i(1, "Subsection Title"),
		t({ "}}", "\\paragraph{\\textbf{" }),
		rep(1),
		t({ "}}", "" }),
		i(2, "Content"),
	}, { condition = conds.line_begin }),
	s(
		{ trig = "par", name = "Paragraph", dscr = "Create a new paragraph", snippetType = "autosnippet" },
		{ t("\\paragraph*{\\textbf{"), i(1, "Paragraph Title"), t("}}") },
		{ condition = conds.line_begin }
	),
}

---------------------------------------------------
-- Категория 2: Математический анализ
---------------------------------------------------

snippets.analysis = {
	s({ trig = "sum", name = "Sum", wordTrig = true, snippetType = "autosnippet" }, {
		t("\\overset{"),
		i(3, "\\infty"),
		t("}{\\underset{"),
		i(1, "i"),
		t(" = "),
		i(2, "1"),
		t("}{\\sum}} "),
		i(4, "a_i"),
	}),
	s(
		{ trig = "lim", name = "Limit", wordTrig = true, snippetType = "autosnippet" },
		{ t("\\underset{"), i(1, "x"), t(" \\to "), i(2, "0"), t("}{\\lim} "), i(3, "f(x)") }
	),
	s(
		{ trig = "int", name = "Integral", wordTrig = true, snippetType = "autosnippet" },
		{ t("\\int "), i(1, "f(x)"), t(" \\;\\mathrm{d} "), i(2, "x") }
	),
	s({ trig = "dint", name = "Definite Integral", priority = 300, snippetType = "autosnippet" }, {
		t("\\int_{"),
		i(1, "-\\infty"),
		t("}^{"),
		i(2, "\\infty"),
		t("} "),
		i(3, "f(x)"),
		t(" \\, \\mathrm{d} "),
		i(4, "x"),
		i(0),
	}),
	s(
		{ trig = "der", name = "Partial Derivative", snippetType = "autosnippet" },
		{ t("\\frac{\\partial "), i(1, "f"), t("}{\\partial "), i(2, "x"), t("} "), i(3) }
	),
	s({ trig = "taylor", name = "Taylor Series", snippetType = "autosnippet" }, {
		t("\\sum_{"),
		i(1, "k"),
		t("="),
		i(2, "0"),
		t("}^{"),
		i(3, "\\infty"),
		t("} "),
		i(4, "c_k"),
		t("(x-a)^{"),
		rep(1),
		t("} "),
		i(0),
	}),
	s(
		{ trig = "inf", name = "Infimum", wordTrig = true, snippetType = "autosnippet" },
		{ t("\\inf\\left\\{"), i(1, "S"), t("\\right\\} "), i(2) }
	),
	s(
		{ trig = "sup", name = "Supremum", wordTrig = true, snippetType = "autosnippet" },
		{ t("\\sup\\left\\{"), i(1, "S"), t("\\right\\} "), i(2) }
	),
	s({ trig = "oo", name = "o-small", wordTrig = true, snippetType = "autosnippet" }, t("\\overline{o}")),
	s({ trig = "OO", name = "O-big", wordTrig = true, snippetType = "autosnippet" }, t("\\underline{O}")),
}

---------------------------------------------------
-- Категория 3: Линейная алгебра
---------------------------------------------------
snippets.linear_algebra = {
	s(
		{ trig = "det", name = "Determinant", wordTrig = true, snippetType = "autosnippet" },
		{ t("\\det\\left("), i(1, "A"), t("\\right) "), i(2) }
	),
	s(
		{ trig = "ov", name = "Vector", wordTrig = true, snippetType = "autosnippet" },
		{ t("\\overrightarrow{"), i(1, "v"), t("} "), i(2) }
	),
	s(
		{ trig = "rk", name = "Rank", wordTrig = true, snippetType = "autosnippet" },
		{ t("\\mathrm{rk}\\left("), i(1, "A"), t("\\right)") }
	),
	s(
		{ trig = "dim", name = "Dimension", wordTrig = true, snippetType = "autosnippet" },
		{ t("\\mathrm{dim}\\left("), i(1, "V"), t("\\right)") }
	),
	s({ trig = "Ker", name = "Kernel", wordTrig = true, snippetType = "autosnippet" }, t("\\mathrm{Ker}")),
	s({ trig = "Im", name = "Image", wordTrig = true, snippetType = "autosnippet" }, t("\\mathrm{Im}")),
	s({ trig = "tr", name = "Trace", wordTrig = true, snippetType = "autosnippet" }, t("\\mathrm{tr}")),
	s(
		{ trig = "pr", name = "Projection", wordTrig = true, snippetType = "autosnippet" },
		{ t("\\mathrm{pr}_{"), i(1, "v"), t("}{"), i(2, "u"), t("}") }
	),
	s(
		{ trig = "ort", name = "Orthogonal", wordTrig = true, snippetType = "autosnippet" },
		{ t("\\mathrm{ort}_{"), i(1, "v"), t("}{"), i(2, "u"), t("}") }
	),
	s({ trig = "opl", name = "Direct Sum", wordTrig = true, snippetType = "autosnippet" }, t("\\oplus")),
	s(
		{ trig = "<<", name = "Inner Product", snippetType = "autosnippet" },
		{ t("\\left\\langle "), i(1, "u, v"), t(" \\right\\rangle") }
	),
	s(
		{ trig = "pmat", name = "pmatrix" },
		{ t({ "\\begin{pmatrix}", "\t" }), i(1, "..."), t({ "", "\\end{pmatrix} " }), i(0) }
	),
	s(
		{ trig = "bmat", name = "bmatrix" },
		{ t({ "\\begin{bmatrix}", "\t" }), i(1, "..."), t({ "", "\\end{bmatrix} " }), i(0) }
	),
	s({ trig = "cvec", name = "Column Vector", snippetType = "autosnippet" }, {
		t("\\begin{pmatrix} "),
		i(1, "x"),
		t("_1 \\\\ \\vdots \\\\ "),
		rep(1),
		t("_"),
		i(2, "n"),
		t(" \\end{pmatrix}"),
	}),
}

---------------------------------------------------
-- Категория 4: Логика и теория множеств
---------------------------------------------------
snippets.logic_and_sets = {
	s({ trig = ";imp", name = "Implication", wordTrig = true, snippetType = "autosnippet" }, t("\\implies")),
	s({ trig = ";and", name = "Logical AND", wordTrig = true, snippetType = "autosnippet" }, t("\\land")),
	s({ trig = ";or", name = "Logical OR", wordTrig = true, snippetType = "autosnippet" }, t("\\lor")),
	s({ trig = ";net", name = "Logical NOT", wordTrig = true, snippetType = "autosnippet" }, t("\\neg")),
	s({ trig = ";eq", name = "Equivalence", wordTrig = true, snippetType = "autosnippet" }, t("\\equiv")),
	s(
		{ trig = "fal", name = "For All", wordTrig = true, snippetType = "autosnippet" },
		{ t("\\forall "), i(1, "x"), t(" \\quad "), i(2) }
	),
	s(
		{ trig = "exs", name = "Exists", wordTrig = true, snippetType = "autosnippet" },
		{ t("\\exists "), i(1, "x"), t(" \\quad "), i(2) }
	),
	s(
		{ trig = "EXS", name = "Exists Unique", wordTrig = true, snippetType = "autosnippet" },
		{ t("\\exists! "), i(1, "x"), t(" \\quad "), i(2) }
	),
	s({ trig = "Uu", name = "Union", snippetType = "autosnippet" }, t("\\cup ")),
	s({ trig = "Aa", name = "Intersection", snippetType = "autosnippet" }, t("\\cap ")),
	s({ trig = "vkl", name = "Subset", wordTrig = true, snippetType = "autosnippet" }, { t("\\subset "), i(1) }),
	s({ trig = "inn", name = "In", snippetType = "autosnippet" }, t("\\in ")),
	s({ trig = "notin", name = "Not In", snippetType = "autosnippet" }, t("\\not\\in ")),
	s({ trig = "cc", name = "Empty Set", wordTrig = true, snippetType = "autosnippet" }, t("\\emptyset ")),
	s({ trig = "cupdot", name = "Disjoint Union", wordTrig = true, snippetType = "autosnippet" }, t("\\sqcup ")),
	s({ trig = [[\\\]], name = "Set Minus", snippetType = "autosnippet" }, t("\\setminus")),
}

---------------------------------------------------
-- Категория 5: Общие математические символы
---------------------------------------------------
snippets.general_math = {
	s(
		{ trig = "uh", name = "Math Environment", wordTrig = true, snippetType = "autosnippet" },
		{ t("$"), i(1), t("$") }
	),
	s({ trig = "dm", name = "Block Math", wordTrig = true }, { t({ "$$", "\t" }), i(1, " "), t({ "", "$$ " }), i(0) }),
	s(
		{ trig = "mk", name = "Inline Math", wordTrig = true, snippetType = "autosnippet" },
		{ t("\\( "), i(1, "x^2"), t(" \\)"), i(0) }
	),
	s({ trig = "sr", name = "Square", snippetType = "autosnippet", wordTrig = false }, t("^2")),
	s({ trig = "cb", name = "Cube", snippetType = "autosnippet", wordTrig = false }, t("^3")),
	s({ trig = "ye", name = "Superscript", snippetType = "autosnippet", wordTrig = false }, { t("^{"), i(1), t("}") }),
	s({ trig = "ft", name = "Subscript", snippetType = "autosnippet", wordTrig = false }, { t("_{"), i(1), t("}") }),
	s(
		{ trig = "sq", name = "Square Root", wordTrig = true, snippetType = "autosnippet" },
		{ t("\\sqrt{"), i(1), t("} "), i(2) }
	),
	s(
		{ trig = "snq", name = "Nth Root", wordTrig = true, snippetType = "autosnippet" },
		{ t("\\sqrt["), i(1, "n"), t("]{"), i(2), t("} "), i(0) }
	),
	s(
		{ trig = "fr", name = "Fraction", snippetType = "autosnippet" },
		{ t("\\frac{"), i(1), t("}{"), i(2), t("} "), i(0) }
	),
	s(
		{
			trig = "([^%s]+)/",
			name = "Simple Word Fraction",
			regTrig = true,
			snippetType = "autosnippet",
			priority = 1001,
		},
		d(1, function(_, parent)
			local numerator = parent.snippet.captures[1]
			-- Простая проверка, чтобы избежать срабатывания на URL-адресах
			if numerator:match(":") then
				return sn(nil, { t(numerator .. "/") })
			end
			return sn(nil, {
				t("\\frac{" .. numerator .. "}{"),
				i(1),
				t("}"),
			})
		end)
	),
	s(
		{ trig = "abs", name = "Absolute Value", snippetType = "autosnippet" },
		{ t("\\left| "), i(1), t(" \\right| "), i(2) }
	),
	s(
		{ trig = "norm", name = "Norm", wordTrig = true, snippetType = "autosnippet" },
		{ t("\\left\\| "), i(1), t(" \\right\\| "), i(2) }
	),
	s({ trig = "Rr", name = "Real Numbers", wordTrig = true, snippetType = "autosnippet" }, t("\\mathbb{R}")),
	s({ trig = "Cc", name = "Complex Numbers", wordTrig = true, snippetType = "autosnippet" }, t("\\mathbb{C}")),
	s({ trig = "Nn", name = "Natural Numbers", wordTrig = true, snippetType = "autosnippet" }, t("\\mathbb{N}")),
	s({ trig = "Zz", name = "Integers", wordTrig = true, snippetType = "autosnippet" }, t("\\mathbb{Z}")),
	s({ trig = "Qq", name = "Rational Numbers", wordTrig = true, snippetType = "autosnippet" }, t("\\mathbb{Q}")),
	s({ trig = "Ff", name = "Field", wordTrig = true, snippetType = "autosnippet" }, t("\\mathbb{F}")),
	s({ trig = "Ee", name = "Euclidean Space", wordTrig = true, snippetType = "autosnippet" }, t("\\mathbb{E}")),
	s({ trig = "!=", name = "Not Equal", snippetType = "autosnippet" }, t("\\ne ")),
	s({ trig = ">=", name = "Greater or Equal", wordTrig = true, snippetType = "autosnippet" }, t("\\ge ")),
	s({ trig = "<=", name = "Less or Equal", wordTrig = true, snippetType = "autosnippet" }, t("\\le ")),
	s({ trig = "xx", name = "Times", snippetType = "autosnippet" }, t("\\times ")),
	s({ trig = "**", name = "Cdot", snippetType = "autosnippet" }, t("\\cdot ")),
	s({ trig = "...", name = "Ellipsis", priority = 100, snippetType = "autosnippet" }, t("\\ldots")),
	s({ trig = "=>", name = "Implies", snippetType = "autosnippet" }, t("\\implies")),
	s({ trig = "->", name = "To", priority = 100, snippetType = "autosnippet" }, t("\\to ")),
	s({ trig = "-->", name = "Long To", priority = 200, snippetType = "autosnippet" }, t("\\longrightarrow ")),
	s({ trig = "!>", name = "Maps to", snippetType = "autosnippet" }, t("\\mapsto ")),
	s({ trig = "siff", name = "Iff", priority = 100, snippetType = "autosnippet" }, t("\\Leftrightarrow")),
	s(
		{ trig = "ras", name = "Right Squiggly Arrow", wordTrig = true, snippetType = "autosnippet" },
		t("\\rightsquigarrow")
	),
	s({ trig = "par", name = "Partial", wordTrig = true, snippetType = "autosnippet" }, t("\\partial")),
	s({ trig = ";in", name = "Infinity", snippetType = "autosnippet" }, t("\\infty")),
}

---------------------------------------------------
-- Категория 6: Текстовые элементы и форматирование
---------------------------------------------------
snippets.text_and_formatting = {
	s(
		{ trig = "Bf", name = "Bold Text", wordTrig = true, snippetType = "autosnippet" },
		{ t("\\textbf{"), i(1, "text"), t("} "), i(2) }
	),
	s(
		{ trig = "tt", name = "Text in Math", wordTrig = true, snippetType = "autosnippet" },
		{ t("\\text{"), i(1, "text"), t("} "), i(2) }
	),
	s(
		{ trig = "rm", name = "Math Roman", wordTrig = true, snippetType = "autosnippet" },
		{ t("\\mathrm{"), i(1, "text"), t("} "), i(2) }
	),
	s(
		{ trig = "mcl", name = "Math Roman", wordTrig = true, snippetType = "autosnippet" },
		{ t("\\mathcal{"), i(1, "text"), t("} "), i(2) }
	),
}

---------------------------------------------------
-- Категория 7: Среды и блоки
---------------------------------------------------
snippets.environments = {
	s(
		{ trig = "beg", name = "Begin/End" },
		{ t("\\begin{"), i(1, "env"), t({ "}", "\t" }), i(0), t({ "", "\\end{" }), rep(1), t("}") },
		{ condition = conds.line_begin }
	),
	s(
		{ trig = "enum", name = "Enumerate" },
		{ t({ "\\begin{enumerate}", "\t\\item " }), i(0), t({ "", "\\end{enumerate}" }) },
		{ condition = conds.line_begin }
	),
	s(
		{ trig = "item", name = "Itemize" },
		{ t({ "\\begin{itemize}", "\t\\item " }), i(0), t({ "", "\\end{itemize}" }) },
		{ condition = conds.line_begin }
	),
	s({ trig = "case", name = "Cases" }, { t({ "\\begin{cases}", "\t" }), i(0), t({ "", "\\end{cases}" }) }),
	s(
		{ trig = "ali", name = "Align" },
		{ t({ "\\begin{align*}", "\t" }), i(1), t({ "", "\\end{align*}" }) },
		{ condition = conds.line_begin }
	),
	s({ trig = "theor", name = "Theorem Block" }, {
		t("\\begin{theorem}{"),
		i(1, "Name"),
		t({ "}{}", "" }),
		i(2, "Content"),
		t({ "", "" }),
		t("\\end{theorem}"),
		t({ "", "" }),
		t("\\begin{proofbox}"),
		t({ "", "" }),
		i(3),
		t({ "", "" }),
		t("\\end{proofbox}"),
	}, { condition = conds.line_begin }),
	s({ trig = "def", name = "Definition Block" }, {
		t("\\begin{definition}{"),
		i(1, "Name"),
		t({ "}{}", "" }),
		i(2, "Content"),
		t({ "", "\t" }),
		t({ "", "\\end{definition}" }),
	}, { condition = conds.line_begin }),
	s({ trig = "exam", name = "Example Block" }, {
		t("\\begin{example}{"),
		i(1, "Name"),
		t({ "}{}", "" }),
		i(2, "Content"),
		t({ "", "\t" }),
		t({ "", "\\end{example}" }),
	}, { condition = conds.line_begin }),
	s({ trig = "rem", name = "Remark Block" }, {
		t("\\begin{remark}{"),
		i(1, "Name"),
		t({ "}{}", "" }),
		i(2, "Content"),
		t({ "", "\t" }),
		t({ "", "\\end{remark}" }),
	}, { condition = conds.line_begin }),
	s({ trig = "cons", name = "Lemma Block" }, {
		t("\\begin{lemma}{"),
		i(1, "Name"),
		t({ "}{}", "" }),
		i(2, "Content"),
		t({ "", "\t" }),
		t({ "", "\\end{lemma}" }),
	}, { condition = conds.line_begin }),
	s({ trig = "task", name = "Task Block" }, {
		t("\\begin{problembox}"),
		t({ "", "" }),
		i(1, "Problem"),
		t({ "", "" }),
		t("\\end{problembox}"),
		t({ "", "" }),
		t("\\begin{solutionbox}"),
		t({ "", "" }),
		i(2, "Solution"),
		t({ "", "" }),
		t("\\end{solutionbox}"),
	}, { condition = conds.line_begin }),
}

---------------------------------------------------
-- Категория 8: Греческие буквы
---------------------------------------------------
snippets.greek_letters = {
	s({ trig = ";a", name = "Alpha", snippetType = "autosnippet" }, t("\\alpha")),
	s({ trig = ";b", name = "Beta", snippetType = "autosnippet" }, t("\\beta")),
	s({ trig = ";g", name = "Gamma", snippetType = "autosnippet" }, t("\\gamma")),
	s({ trig = ";s", name = "sigma", snippetType = "autosnippet" }, t("\\sigma")),
	s({ trig = ";S", name = "sigma", snippetType = "autosnippet" }, t("\\Sigma")),
	s({ trig = ";D", name = "delta", snippetType = "autosnippet" }, t("\\delta")),
	s({ trig = ";e", name = "Epsilon", snippetType = "autosnippet" }, t("\\epsilon")),
	s({ trig = ";l", name = "Lambda", snippetType = "autosnippet" }, t("\\lambda")),
	s({ trig = ";E", name = "Up epsilon", snippetType = "autosnippet" }, t("\\mathcal{E}")),
	s({ trig = ";x", name = "Xi", snippetType = "autosnippet" }, t("\\xi")),
	s({ trig = ";z", name = "Zeta", snippetType = "autosnippet" }, t("\\zeta")),
	s({ trig = ";O", name = "Omega", snippetType = "autosnippet" }, t("\\Omega")),
	s({ trig = ";o", name = "omega", snippetType = "autosnippet" }, t("\\omega ")),
	s(
		{ trig = "pi", name = "Pi", snippetType = "autosnippet" },
		t("\\uppi"),
		{ condition = not_preceded_by_bs_or_letter("pi") }
	),
	s(
		{ trig = "phi", name = "Phi", snippetType = "autosnippet" },
		t("\\varphi"),
		{ condition = not_preceded_by_bs_or_letter("phi") }
	),
	s(
		{ trig = "psi", name = "Psi", snippetType = "autosnippet" },
		t("\\psi"),
		{ condition = not_preceded_by_bs_or_letter("psi") }
	),
	s(
		{ trig = "Al", name = "Algebra", snippetType = "autosnippet" },
		t("\\mathscr{F}"),
		{ condition = not_preceded_by_bs_or_letter("Al") }
	),
}

---------------------------------------------------
-- Категория 9: Скобки и разделители
---------------------------------------------------
snippets.delimiters = {
	s(
		{ trig = "kk", name = "Parentheses", wordTrig = true, snippetType = "autosnippet" },
		{ t("\\left( "), i(1), t(" \\right)") }
	),
	s(
		{ trig = "{{", name = "Set Braces", wordTrig = true, snippetType = "autosnippet" },
		{ t("\\left\\{"), i(1), t(" \\right\\} "), i(2) }
	),
	s(
		{ trig = "lr|", name = "left| right|", snippetType = "autosnippet" },
		{ t("\\left| "), i(1), t(" \\right| "), i(0) }
	),
	s(
		{ trig = "[[", name = "left[ right]", snippetType = "autosnippet" },
		{ t("\\left[ "), i(1), t(" \\right] "), i(0) }
	),
	s(
		{ trig = "<<", name = "left< right>", snippetType = "autosnippet" },
		{ t("\\left< "), i(1), t(" \\right> "), i(0) }
	),
}

---------------------------------------------------
-- Категория 10: Постфиксные и Автоматические Сниппеты
---------------------------------------------------
snippets.postfix_and_auto = (function()
	local result = {}

	-- Генератор постфиксов: с проверкой, чтобы не срабатывать после '\' или буквы
	local function generate_postfix_snippets(triggers)
		local snippets_list = {}
		for _, trigger_word in ipairs(triggers) do
			local tw = trigger_word -- замыкание
			table.insert(
				snippets_list,
				s({
					name = "Postfix: " .. tw,
					trig = "(" .. tw .. ")%s*",
					regTrig = true,
					wordTrig = false,
					priority = 200,
					snippetType = "autosnippet",
				}, {
					f(function(_, snip)
						return "\\" .. snip.captures[1]
					end, {}),
				}, {
					condition = not_preceded_by_bs_or_letter(tw),
				})
			)
		end
		return snippets_list
	end

	local func_triggers = { "sin", "cos", "tan", "csc", "sec", "cot", "ln", "log", "exp", "arcsin", "arctan", "arcsec" }
	local greek_triggers = {
		"alpha",
		"beta",
		"gamma",
		"delta",
		"epsilon",
		"zeta",
		"eta",
		"theta",
		"iota",
		"kappa",
		"lambda",
		"mu",
		"nu",
		"xi",
		"pi",
		"rho",
		"sigma",
		"tau",
		"phi",
		"chi",
		"psi",
		"omega",
		"Alpha",
		"Beta",
		"Gamma",
		"Delta",
		"Epsilon",
		"Zeta",
		"Eta",
		"Theta",
		"Iota",
		"Kappa",
		"Lambda",
		"Mu",
		"Nu",
		"Xi",
		"Pi",
		"Rho",
		"Sigma",
		"Tau",
		"Phi",
		"Chi",
		"Psi",
		"Omega",
		"varepsilon",
		"varphi",
		"varrho",
		"vartheta",
	}

	vim.list_extend(result, generate_postfix_snippets(func_triggers))
	vim.list_extend(result, generate_postfix_snippets(greek_triggers))

	local vec_node = f(function(_, snip)
		return string.format("\\vec{%s} ", snip.captures[1])
	end, {})

	local auto_vector_triggers = {
		"([%a][%a])(%.,)",
		"([%a][%a])(,%.)",
		"([%a])(%.,)",
		"([%a])(,%.)",
	}
	for _, trig_pattern in ipairs(auto_vector_triggers) do
		table.insert(
			result,
			s({
				trig = trig_pattern,
				name = "Auto Vector",
				regTrig = true,
				snippetType = "autosnippet",
			}, { vec_node })
		)
	end

	return result
end)()

---------------------------------------------------
-- Категория 11: Разное и Пользовательские
---------------------------------------------------
snippets.misc = {
	s(
		{ trig = "([%a])(%d)", name = "Auto Subscript", regTrig = true, snippetType = "autosnippet" },
		f(function(_, snip)
			return string.format("%s_{%s}", snip.captures[1], snip.captures[2])
		end, {})
	),
	s(
		{ trig = "([%a])_(%d%d)", name = "Auto Subscript 2", regTrig = true, snippetType = "autosnippet" },
		f(function(_, snip)
			return string.format("%s_{%s}", snip.captures[1], snip.captures[2])
		end, {})
	),
	s(
		{
			trig = ".*%)/",
			name = "() Fraction",
			wordTrig = true,
			regTrig = true,
			priority = 1000,
			snippetType = "autosnippet",
		},
		d(1, function(_, parent)
			local stripped = parent.snippet.trigger
			stripped = stripped:sub(1, #stripped - 1) -- убираем завершающий '/'
			local depth = 0
			local idx = #stripped
			while idx >= 1 do
				if stripped:sub(idx, idx) == ")" then
					depth = depth + 1
				elseif stripped:sub(idx, idx) == "(" then
					depth = depth - 1
				end
				if depth == 0 then
					break
				end
				idx = idx - 1
			end
			if depth ~= 0 then
				return sn(nil, { t(stripped .. "\\frac{}{}"), i(1), i(0) })
			else
				return sn(nil, {
					t(stripped:sub(1, idx - 1) .. "\\frac{" .. stripped:sub(idx + 1, #stripped) .. "}{"),
					i(1),
					t("}"),
					i(0),
				})
			end
		end)
	),
	s({ trig = "hat", name = "hat", priority = 10, snippetType = "autosnippet" }, { t("\\hat{"), i(1), t("} "), i(0) }),
	s(
		{ trig = "bar", name = "bar", priority = 10, snippetType = "autosnippet" },
		{ t("\\overline{"), i(1), t("} "), i(0) }
	),
	s(
		{ trig = "(%a+)bar", regTrig = true, name = "bar word", priority = 100, snippetType = "autosnippet" },
		f(function(_, snip)
			return string.format("\\overline{%s}", snip.captures[1])
		end, {})
	),
	s(
		{ trig = "(%a+)und", regTrig = true, name = "underline", priority = 100, snippetType = "autosnippet" },
		f(function(_, snip)
			return string.format("\\underline{%s}", snip.captures[1])
		end, {})
	),
	s(
		{ trig = "(%a)dot", regTrig = true, name = "dot", priority = 100, snippetType = "autosnippet" },
		f(function(_, snip)
			return string.format("\\dot{%s}", snip.captures[1])
		end, {})
	),
	s(
		{ trig = "(%a+)hat", regTrig = true, name = "hat word", priority = 100, snippetType = "autosnippet" },
		f(function(_, snip)
			return string.format("\\hat{%s}", snip.captures[1])
		end, {})
	),
	s(
		{
			trig = "(%a+)ora",
			regTrig = true,
			name = "Over Right Arrow",
			priority = 100,
			snippetType = "autosnippet",
		},
		f(function(_, snip)
			return string.format("\\overrightarrow{%s}", snip.captures[1])
		end, {})
	),
	s(
		{
			trig = "(%a+)ola",
			regTrig = true,
			name = "Over Left Arrow",
			priority = 100,
			snippetType = "autosnippet",
		},
		f(function(_, snip)
			return string.format("\\overleftarrow{%s}", snip.captures[1])
		end, {})
	),

	s({ trig = "lr", name = "Left right arrow", snippetType = "autosnippet" }, t("\\Leftrightarrow")),
	s({ trig = "ra", name = " Right arrow", snippetType = "autosnippet" }, t("\\Rightarrow")),
	s({ trig = "+.", name = "Plus-ldots", snippetType = "autosnippet" }, t("+ \\ldots + ")),
	s({ trig = ",.", name = "Comma-ldots", snippetType = "autosnippet" }, t(", \\ldots , ")),
	s(
		{ trig = "mod", name = "Modulo", wordTrig = true, snippetType = "autosnippet" },
		{ t("\\pmod{"), i(1), t("} "), i(2) }
	),
	s({ trig = "mcal", name = "Mathcal", snippetType = "autosnippet" }, { t("\\mathcal{"), i(1), t("} "), i(0) }),
}

-- Функция для сбора и возврата всех сниппетов из всех категорий
local function get_all_snippets()
	local all_snippets = {}
	for _, category_snippets in pairs(snippets) do
		for _, snippet in ipairs(category_snippets) do
			table.insert(all_snippets, snippet)
		end
	end
	return all_snippets
end

-- Возвращаем все сниппеты для загрузки в LuaSnip
return get_all_snippets()
