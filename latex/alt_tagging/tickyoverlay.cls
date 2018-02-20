\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{tickyoverlay}[2018/02/15 - Valentines Day Edition]

% Load base class and setup page
\LoadClass[12pt]{article}
\RequirePackage{fourier}
\RequirePackage[letterpaper, margin=0in]{geometry}
\setlength{\parindent}{0in}
\pagestyle{empty}

% Load packages for drawing the gradebox overlays.
\RequirePackage{tikz}
\usetikzlibrary{calc}
\RequirePackage{keyval}
\RequirePackage{ifthen}
\newcommand{\ifnotthen}[2]{\ifthenelse{#1}{\relax}{#2}}
\newcommand{\ifthen}[2]{\ifthenelse{#1}{#2}{\relax}}

% Setup QR code generator.  If in LuaTeX, use it to compute the QR
% codes for a 2x speedup.

\RequirePackage{ifluatex}

\ifluatex
  \RequirePackage{luacode}
  \begin{luacode}
    qrcodelib = dofile("qrencode.lua")

    local function black_box(size)
      return "\\rule{"..size.."}{"..size.."}"
    end

    local function white_box(size)
      return "\\rule{"..size.."}{0pt}"
    end

    function qrcode(s)
      -- Generate a 1cm x 1cm qrcode
      local ok, tab_or_message = qrcodelib.qrcode(s)
      local buffer = {}
      local write_nl = function(text)
	table.insert(buffer,text)
      end
      if not ok then
	print(tab_or_message)
      else
	local x = #tab_or_message[1]
	local y = #tab_or_message
	local w = (1/x .. "cm")
	write_nl("\\begin{minipage}{1cm}")
	write_nl("\\baselineskip="..w)
	for i = 1, x, 1 do
	  local boxes = {}
	  for n = 1, y, 1 do
	    local p = tab_or_message[n][i] > 0  and black_box(w) or white_box(w)
	    table.insert(boxes,p)
	  end
	  write_nl(table.concat(boxes).."\\par")
	end
	write_nl("\\end{minipage}")
      end
      return table.concat(buffer,"")
    end
  \end{luacode}

  \newcommand\nmd@qrcode[1]{%
    \directlua{%
      tex.print(qrcode("\luatexluaescapestring{#1}"))
    }
  }
\else % In plain PDFLaTeX
  \RequirePackage[nolinks]{qrcode}
  \newcommand{\nmd@qrcode}[1]{\qrcode[height=1cm]{#1}}
\fi

 \renewcommand{\nmd@qrcode}[1]{\relax}

% The main grader answer area is 14.5 x 1.6 cm, with an aspect ratio
% 9.025

% Arguments are what goes in the QR code and the page max
\newcommand{\graderbox}[2]{
  \begin{tikzpicture}
    \graderboxguts{#1}{#2}
  \end{tikzpicture}
}


% Draw UIN entry area
\newcommand{\drawUINentrybox}{%
  \begin{scope}[scale=1.0011, shift={(11.79cm, 22.23cm)}]
    \newcommand{\s}{0.8}
    \draw[line width=1pt] (0, 2.0*\s) rectangle (10*\s, -10.5*\s);
    \node[below right=3pt] at (0, 2.0*\s) {\bf  Write and bubble in your UIN:};

    \draw[line width=1pt] (0, 0.2) -- +(10*\s, 0);
    \foreach \u in {0,...,7}{
      \draw[line width=1pt] (1.5*\s + \s*\u, 0.2) -- +(0, 0.3);
    }

    \foreach \u in {0,...,8}{
      \foreach \d in {0,...,9}{
        \node[draw, circle] at (\s + \s*\u, -0.5*\s - \s*\d) {\scriptsize \d};
      }
    }
  \end{scope}
}

\newcommand{\graderboxguts}[2]{
  \fill[color=white] (0, 0) rectangle (21.59, 2.3);
  \begin{scope}[line width=1.5pt]
    \draw (0, 2.3) -- +(21.59, 0);
    \draw (2.3, 0) -- +(0, 2.3);
    \draw (4.5, 0) -- +(0, 2.3);
    \draw (19.0, 0) -- +(0, 2.3);
    \draw (4.5, 0.7) -- (19, 0.7);
    \node at (3.4, 0.7) {Page score};
  \end{scope}

  \node at (1.5, 1.5) {\nmd@qrcode{#1}};
  \node at (20, 1.5) {\nmd@qrcode{#1}};

  \ifnotthen{\equal{#2}{0}}{
    \foreach \x in {0,1,...,#2}{
      \coordinate (p) at (5.25 + 1.3*\x, 1.5);
      \node[draw, minimum size=0.4cm] at (p) {\x};
      \node[draw, minimum size=0.8cm, line width=0.5pt, style=dashed] at (p) {};
    };
  }

  \ifthen{\equal{#2}{0}}{
    \drawUINentrybox
  }
}




\define@key{examspec}{examfile}{\def\nmd@examfile{#1}}
\define@key{examspec}{coverfile}{\def\nmd@examcover{#1}}
\define@key{examspec}{pagemaxes}{\def\nmd@pagemaxes{#1}}
\define@key{examspec}{room}{\def\nmd@examroom{#1}}
\define@key{examspec}{term}{\def\nmd@examterm{#1}}
\define@key{examspec}{name}{\def\nmd@examname{#1}}
\define@key{examspec}{version}{\def\nmd@examversion{#1}}
\define@key{examspec}{CRN}{\def\nmd@examCRN{#1}}
\define@key{examspec}{examnum}{\def\nmd@examnum{#1}}
\define@key{examspec}{page}{\def\nmd@exampage{#1}}
\define@key{examspec}{pagemax}{\def\nmd@exampagemax{#1}}

% Arguments are pagenum and pagemax
\newcommand{\pagewithoverlay}{
  \begin{tikzpicture}
    \node[inner sep=0pt] at (0,0) {%
      \ifthenelse{\equal{\nmd@exampage}{1}}
      {% Cover page
        \includegraphics[page=1, trim=1 1 1 1, clip]{\nmd@examcover}}%
      {% All other pages
        \includegraphics[page=\numexpr\nmd@exampage-1\relax, trim=1 1 1 1, clip]{\nmd@examfile}}%
    };
    
    \begin{scope}[scale=0.997, shift={(-10.795, -13.98)}]
      \graderboxguts{%
        \nmd@examterm,\nmd@examCRN,\nmd@examname,\nmd@examversion,\nmd@examnum,\nmd@exampage,\nmd@exampagemax}%
      {\nmd@exampagemax}
    \end{scope}
    \node at (-9.3, -13.35) {Ex \nmd@examnum};
    \node at (9.2, -13.35) {Ex \nmd@examnum};

    % Print seat if this is the first page.
    \ifthen{\equal{\nmd@exampage}{1}}{ 
      \node[right=3pt] at (2.4, 12.81) {\huge \bf \nmd@examroom};
    }
  \end{tikzpicture}

  \pagebreak
}


\newcommand{\examdefaults}[1]{
    \setkeys{examspec}{#1}
}


\newcommand{\overlayexam}[3][]{
  \setkeys{examspec}{#1}
  \foreach \pagemax [count=\pagenum] in \nmd@pagemaxes {
    \setkeys{examspec}{page=\pagenum, pagemax=\pagemax, room=#2, examnum=#3}
    \pagewithoverlay
  }
}
