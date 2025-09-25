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
	s("Preamble", {
		t({
			"\\documentclass[a4paper, 12pt]{article}",
			"\\usepackage[T2A]{fontenc}",
			"\\usepackage{hyperref}",
			"\\usepackage{ upgreek }",
			"",
			"\\usepackage[russian, english]{babel}",
			"\\usepackage[utf8]{inputenc}",
			"\\usepackage{subfiles}",
			"\\usepackage{ucs}",
			"\\usepackage{textcomp}",
			"\\usepackage{array}",
			"\\usepackage{indentfirst}",
			"\\usepackage{amsmath}",
			"\\usepackage{amssymb}",
			"\\usepackage{enumerate}",
			"\\usepackage[margin=0.75cm]{geometry}",
			"\\usepackage{authblk}",
			"\\usepackage[most]{tcolorbox}",
			"\\usepackage{tikz}",
			"\\usepackage{icomma}",
			"\\usepackage{gensymb}",
			"\\linespread{1.8}",
			"\\everymath{\\displaystyle}",
			"\\tcbuselibrary{breakable, skins}  % Для теней и разрывов страниц",
			"\\usepackage{fancyhdr}             % Для колонтитулов",
			"\\usepackage{lipsum}               % Для примера текста",
			"\\usepackage{enumitem}             % Для стилизации списков",
			"\\usepackage{xcolor}               % Для управления цветами",
			"\\usepackage{geometry}",
			"\\usepackage{graphicx}",
			"\\usepackage{float}",
			"\\usepackage{wrapfig}",
			"",
			"\\pagestyle{fancy}",
			"\\fancyhf{}",
		}),
		t("\\fancyhead[L]{\\small \\textit{"),
		i(1, "Title"),
		t("}}"),
		t("\\fancyhead[R]{\\small \\textit{"),
		i(2, "Subtitle"),
		t("}}"),
		t({
			"\\fancyfoot[C]{\\thepage}",
			"\\usepackage{lmodern}",
			"\\usepackage{import}",
			"\\usepackage{xifthen}",
			"\\usepackage{pdfpages}",
			"\\usepackage{transparent}",
			"\\usepackage[dvipsnames,svgnames]{xcolor}",
			"",
			"% Настройка полей",
			"\\geometry{left=0.5cm, right=0.5cm, top=2.5cm, bottom=2.5cm}",
			"",
			"% Цветовая схема",
			"\\definecolor{problemblue}{RGB}{173, 216, 230}",
			"\\definecolor{solutiongreen}{RGB}{144, 238, 144}",
			"\\definecolor{accentpurple}{RGB}{147, 112, 219}",
			"\\definecolor{definitiongray}{RGB}{211, 211, 211}",
			"\\definecolor{theoremblue}{RGB}{173, 216, 230}",
			"\\definecolor{lemmayellow}{RGB}{255, 255, 224}",
			"\\definecolor{remarkpurple}{RGB}{216, 191, 216}",
			"\\definecolor{propositiongreen}{RGB}{144, 238, 144}",
			"\\definecolor{exampleorange}{RGB}{255, 228, 181}",
			"",
			"\\newcounter{my_c}",
			"",
			"% Среда для задач с иконкой и тенью",
			"\\newtcolorbox[auto counter]{problembox}[1][]{",
			"    colback=problemblue!20,",
			"    colframe=problemblue!75!black,",
			"    coltitle=white,",
			"    fonttitle=\\bfseries,",
			"    title={\\protect\\begin{tikzpicture}[baseline=-0.5ex]",
			"        \\node[circle, fill=problemblue!75!black, inner sep=2pt] {\\color{white}};",
			"\\end{tikzpicture}\\ Задача \\thetcbcounter},",
			"    breakable, enhanced, drop shadow={black!50!white},",
			"    left=6mm, right=6mm, top=3mm, bottom=3mm, boxrule=1pt, arc=5pt,",
			"    #1",
			"}",
			"",
			"\\newtcolorbox{proofbox}{",
			"    colback=gray!5,",
			"    colframe=gray!75!black,",
			"    fonttitle=\\bfseries,",
			"    title=Доказательство,",
			"    boxrule=1pt,",
			"    arc=5pt,",
			"    left=5mm, right=5mm, top=2mm, bottom=2mm",
			"}",
			"",
			"% Среда для решений с тенью",
			"\\newtcolorbox{solutionbox}[1][]{",
			"    colback=solutiongreen!20,",
			"    colframe=solutiongreen!75!black,",
			"    coltitle=white,",
			"    fonttitle=\\bfseries,",
			"    title={\\protect\\begin{tikzpicture}[baseline=-0.5ex]",
			"        \\node[rectangle, fill=solutiongreen!75!black, inner sep=2pt] {\\color{white}\\tiny\\checkmark};",
			"\\end{tikzpicture}\\ Решение},",
			"    breakable, enhanced, drop shadow={black!50!white},",
			"    left=6mm, right=6mm, top=3mm, bottom=3mm, boxrule=1pt, arc=5pt,",
			"    #1",
			"}",
			"",
			"% Определение для теорем и других утверждений",
			"\\newtcbtheorem[auto counter, number within=section]{definition}{Определение}{",
			"    colback=definitiongray!10,",
			"    colframe=definitiongray!75!black,",
			"    fonttitle=\\bfseries,",
			"    title=Определение \\thetcbcounter,",
			"    breakable, enhanced, drop shadow={black!50!white},",
			"    left=6mm, right=6mm, top=3mm, bottom=3mm, boxrule=1pt, arc=5pt",
			"}{def}",
			"",
			"\\newtcbtheorem[auto counter, number within=section]{theorem}{Теорема}{",
			"    colback=theoremblue!10,",
			"    colframe=theoremblue!75!black,",
			"    fonttitle=\\bfseries,",
			"    title=Теорема \\thetcbcounter,",
			"    breakable, enhanced, drop shadow={black!50!white},",
			"    left=6mm, right=6mm, top=3mm, bottom=3mm, boxrule=1pt, arc=5pt",
			"}{th}",
			"",
			"\\newtcbtheorem[auto counter, number within=section]{lemma}{Следствие}{",
			"    colback=lemmayellow!10,",
			"    colframe=lemmayellow!75!black,",
			"    fonttitle=\\bfseries,",
			"    title=Лемма \\thetcbcounter,",
			"    breakable, enhanced, drop shadow={black!50!white},",
			"    left=6mm, right=6mm, top=3mm, bottom=3mm, boxrule=1pt, arc=5pt",
			"}{lem}",
			"",
			"\\newtcbtheorem[auto counter, number within=section]{remark}{Замечание}{",
			"    colback=remarkpurple!10,",
			"    colframe=remarkpurple!75!black,",
			"    fonttitle=\\bfseries,",
			"    title=Замечание \\thetcbcounter,",
			"    breakable, enhanced, drop shadow={black!50!white},",
			"    left=6mm, right=6mm, top=3mm, bottom=3mm, boxrule=1pt, arc=5pt",
			"}{rem}",
			"",
			"\\newtcbtheorem[auto counter, number within=section]{proposition}{Предложение}{",
			"    colback=propositiongreen!10,",
			"    colframe=propositiongreen!75!black,",
			"    fonttitle=\\bfseries,",
			"    title=Предложение \\thetcbcounter,",
			"    breakable, enhanced, drop shadow={black!50!white},",
			"    left=6mm, right=6mm, top=3mm, bottom=3mm, boxrule=1pt, arc=5pt",
			"}{prop}",
			"",
			"\\newtcbtheorem[auto counter, number within=section]{example}{Пример}{",
			"    colback=exampleorange!10,",
			"    colframe=exampleorange!75!black,",
			"    fonttitle=\\bfseries,",
			"    title=Пример \\thetcbcounter,",
			"    breakable, enhanced, drop shadow={black!50!white},",
			"    left=6mm, right=6mm, top=3mm, bottom=3mm, boxrule=1pt, arc=5pt",
			"}{ex}",
			"",
			"% Настройка гиперссылок",
			"\\hypersetup{",
			"    colorlinks=true,",
			"    linkcolor=accentpurple,",
			"    urlcolor=accentpurple",
			"}",
			"",
			"\\newcommand{\\incfig}[2][1]{%",
			"    \\def\\svgwidth{#1\\columnwidth}",
			"    \\import{./figures/}{#2.pdf_tex}",
			"}",
			"",
			"\\pdfsuppresswarningpagegroup=1",
			"",
			"\\makeatletter",
			"\\renewcommand*\\env@matrix[1][*\\c@MaxMatrixCols c]{%",
			"  \\hskip -\\arraycolsep",
			"  \\let\\@ifnextchar\\new@ifnextchar",
			"  \\array{#1}}",
			"\\makeatother",
			"",
		}),
		t({
			"\\begin{document}",
			"",
			"\\begin{center}",
			"    {\\Large \\textbf{\\textcolor{accentpurple}{",
		}),
		rep(1),
		t({
			"}}} \\\\",
			"    \\vspace{5mm}",
			"    {\\normalsize ",
		}),
		rep(2),
		t({
			"} \\\\",
			"    {\\small \\today}",
			"\\end{center}",
			"",
		}),
		i(0),
		t({
			"",
			"\\end{document}",
		}),
	}),
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
	s({ trig = "imp", name = "Implication", wordTrig = true, snippetType = "autosnippet" }, t("\\implies")),
	s({ trig = "and", name = "Logical AND", wordTrig = true, snippetType = "autosnippet" }, t("\\land")),
	s({ trig = ";or", name = "Logical OR", wordTrig = true, snippetType = "autosnippet" }, t("\\lor")),
	s({ trig = "net", name = "Logical NOT", wordTrig = true, snippetType = "autosnippet" }, t("\\neg")),
	s({ trig = "eq", name = "Equivalence", wordTrig = true, snippetType = "autosnippet" }, t("\\equiv")),
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
		{ trig = "||", name = "Norm", wordTrig = true, snippetType = "autosnippet" },
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

	s(
		{ trig = "del", name = "delta", snippetType = "autosnippet" },
		t("\\delta"),
		{ condition = not_preceded_by_bs_or_letter("del") }
	),
	s(
		{ trig = "Del", name = "Delta", snippetType = "autosnippet" },
		t("\\Delta"),
		{ condition = not_preceded_by_bs_or_letter("Del") }
	),
	s(
		{ trig = "eps", name = "Epsilon", snippetType = "autosnippet" },
		t("\\epsilon"),
		{ condition = not_preceded_by_bs_or_letter("eps") }
	),
	s(
		{ trig = "lam", name = "Lambda", snippetType = "autosnippet" },
		t("\\lambda"),
		{ condition = not_preceded_by_bs_or_letter("lam") }
	),
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
		{ trig = "Om", name = "Omega", snippetType = "autosnippet" },
		t("\\Omega"),
		{ condition = not_preceded_by_bs_or_letter("Om") }
	),
	s(
		{ trig = "om", name = "omega", snippetType = "autosnippet" },
		t("\\omega "),
		{ condition = not_preceded_by_bs_or_letter("om") }
	),
	s(
		{ trig = "Al", name = "Algebra", snippetType = "autosnippet" },
		t("\\mathscr{F}"),
		{ condition = not_preceded_by_bs_or_letter("Al") }
	),

	s({ trig = ";x", name = "Xi", snippetType = "autosnippet" }, t("\\xi")),
	s({ trig = ";z", name = "Zeta", snippetType = "autosnippet" }, t("\\zeta")),
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
		{ trig = "lra", name = "left< right>", snippetType = "autosnippet" },
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
	s({ trig = "+..", name = "Plus-ldots", snippetType = "autosnippet" }, t("+ \\ldots + ")),
	s({ trig = ",..", name = "Comma-ldots", snippetType = "autosnippet" }, t(", \\ldots , ")),
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
