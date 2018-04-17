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

% Need for compatibility with LuaTeX 0.95 and newer.
\ifthen{\isundefined{\pdfliteral}}{%
    \protected\def\pdfliteral{\pdfextension literal}}

% Putting bitmaps directly in the PDF file as 1cm boxes.
% Adapted from https://github.com/zerotoc/pdfinlimg

\newcommand{\pdfinlineimage}[2]{
\begin{minipage}[c]{1.01cm}
\makebox[1cm][l]{\immediate\pdfliteral{
  q
  28.346456 0 0 28.346456 0 0 cm
  BI
  /W #1
  /H #1
  /CS /G
  /BPC 1
  /I false
  /F [ /AHx ]
  ID
  #2>
  EI
  Q
}\vbox to 1cm{}}
\end{minipage}
}

% Setup QR code generator.  If in LuaTeX, use it to compute the QR
% codes for a massive speedup.  To work around a buggy PDF renderers
% from Apple and Xerox that ignore the interpolate = false flag in
% some bitmapped images, we encode each block of the QR code as a grid
% of 8 x 8 pixels.

\RequirePackage{ifluatex}

\ifluatex
  \RequirePackage{luacode}
  \begin{luacode}
    qrcodelib = dofile("qrencode.lua")
  
    function qrcode(s)
      -- Generate a 1cm x 1cm qrcode
      local ok, QR = qrcodelib.qrcode(s)
      local buffer = {}

      local write = function(text)
        table.insert(buffer,text)
      end

      if not ok then
        print(QR)
      else
        local n = #QR
        assert(n == #QR[1], "QR code not square")
        texio.write_nl('<QR encoded "'..s..'" at version '..((n - 17)/4)..'>')

        write("\\pdfinlineimage{"..8*n.."}{")
        for i = 1, n, 1 do
          for k = 1, 8, 1 do
            for j = 1, #QR, 1 do
              write(QR[j][i] > 0 and "00" or "FF")
            end
            write(" ") 
          end  
        end
      write("}")
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

% The main grader answer area is 14.5 x 1.6 cm, with an aspect ratio
% 9.025

% Arguments are what goes in the QR code and the page max
\newcommand{\graderbox}[2]{
  \begin{tikzpicture}
    \graderboxguts{#1}{#2}
  \end{tikzpicture}
}


\newsavebox{\nmd@UINentrybox}
% Draw UIN entry area
\sbox{\nmd@UINentrybox}{%
  \begin{tikzpicture}
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
  \end{tikzpicture}
}

\newsavebox{\nmd@ticksavebox}

\sbox{\nmd@ticksavebox}{%
  \begin{tikzpicture}[xscale=0.9984]
    \foreach \x in {0,1,...,10}{
      \coordinate (p) at (1.3*\x, 0);
      \node[draw, minimum size=0.4cm] at (p) {\x};
      \node[draw, minimum size=0.8cm, line width=0.5pt, style=dashed] at (p) {};
    };
  \end{tikzpicture}
}


\newsavebox{\nmd@qrsavedbox}

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

  \sbox{\nmd@qrsavedbox}{\nmd@qrcode{#1}}
  \node at (1.5, 1.5) {\usebox{\nmd@qrsavedbox}};
  \node at (20, 1.5) {\usebox{\nmd@qrsavedbox}};

  \ifnotthen{\equal{#2}{0}}{
    %\foreach \x in {0,1,...,#2}{
    %  \coordinate (p) at (5.25 + 1.3*\x, 1.5);
    %  \node[draw, minimum size=0.4cm, red] at (p) {\x};
    %  \node[draw, minimum size=0.8cm, red, line width=0.5pt, style=dashed] at (p) {};
    %};
    \node[inner sep=0pt, outer sep=0pt, anchor=west] at (4.85, 1.5) {\usebox{\nmd@ticksavebox}};
    %\fill[green, opacity=0.1]  (4.7, 1.0) rectangle (18.85, 2.0);
    \fill[white] (5.9 + 1.3*#2, 1) rectangle (18.85, 2);
  }

  \ifthen{\equal{#2}{0}}{
    \node[inner sep=0pt, anchor=north west] at (11.775cm, 23.885cm) {\usebox{\nmd@UINentrybox}};
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
