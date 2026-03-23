%%
%% This is file `letinbiom.cls',
%% built from the standard `article' document class.
%%
%% Structure of this file is borrowed extensively from
%% ``The LaTeX Companion'' 2nd edition.
%% All page number references are for TLC2e.
%%

% ------------------------------------------------------------------------------
%   Identification
% ------------------------------------------------------------------------------
\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{letinbiom}
              [2015/08/05 v1.0
 Letters in Biomathematics document class]

% ------------------------------------------------------------------------------
%  Initial Code
% ------------------------------------------------------------------------------
%\RequirePackage{calc}
%\RequirePackage{ifthen}

% ------------------------------------------------------------------------------
%  Declaration of Options
% ------------------------------------------------------------------------------
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{article}}
\DeclareOption{research}{\def\ArticleType{Research}}
\DeclareOption{education}{\def\ArticleType{Education}}
\DeclareOption{review}{\def\ArticleType{Review}}
\PassOptionsToClass{twoside}{article}

% ------------------------------------------------------------------------------
%  Execution of Options
% ------------------------------------------------------------------------------
\ExecuteOptions{research}
\ProcessOptions \relax

% ------------------------------------------------------------------------------
%  Package Loading
% ------------------------------------------------------------------------------
\LoadClass{article}
\RequirePackage{geometry}
\RequirePackage{fancyhdr}
\RequirePackage{color}
\RequirePackage[pagewise]{lineno}

% ------------------------------------------------------------------------------
%  Main Code
% ------------------------------------------------------------------------------

% declare the color of the special text
\definecolor{TFBlue}{RGB}{6,12,129}

% the default page markup settings
\geometry{letterpaper, inner=2.4cm, outer=2.4cm, top=2.1cm, bottom=2.1cm}
\linenumbers

%% Non-cover page material
\pagestyle{fancy}
\fancyhf{}
%\renewcommand\headrulewidth{0pt}
\lhead[\thepage\qquad\MakeUppercase{\@authorheading}]{}
\rhead[]{LETTERS IN BIOMATHEMATICS\qquad\thepage}

%\lhead[<even output>]{<odd output>}
%\chead[<even output>]{<odd output>}
%\rhead[<even output>]{<odd output>}

%\lfoot[<even output>]{<odd output>}
%\cfoot[<even output>]{<odd output>}
%\rfoot[<even output>]{<odd output>}

\newcommand\authorheading[1]{\gdef\@authorheading{#1}}
\renewcommand\abstract[1]{\gdef\@abstract{#1}}
\newcommand\keywords[1]{\gdef\@keywords{#1}}
\newcommand\keywordsname{Keywords}

\def\@abstract{(no abstract)}
\def\@keywords{(no keywords)}

\renewcommand\maketitle{\par
  \begingroup
%    \renewcommand\thefootnote{\@fnsymbol\c@footnote}%
%    \def\@makefnmark{\rlap{\@textsuperscript{\normalfont\@thefnmark}}}%
    \long\def\@makefntext##1{\parindent 1.8em\noindent
            \hb@xt@1.8em{%
                \hss\@textsuperscript{\normalfont\@thefnmark}}##1}%
%    \if@twocolumn
%      \ifnum \col@number=\@ne
%        \@maketitle
%      \else
%        \twocolumn[\@maketitle]%
%      \fi
%    \else
      \newpage
      \global\@topnum\z@   % Prevents figures from going at top of page.
      \@maketitle
%    \fi
    \thispagestyle{plain}\@thanks
  \endgroup
  \setcounter{footnote}{0}%
  \global\let\thanks\relax
  \global\let\maketitle\relax
  \global\let\@maketitle\relax
  \global\let\@thanks\@empty
  \global\let\@author\@empty
  \global\let\@date\@empty
  \global\let\@title\@empty
  \global\let\title\relax
  \global\let\author\relax
  \global\let\date\relax
  \global\let\and\relax
}

\def\@maketitle{%
  \newpage
  \null
  \vskip 4em%
%  \hspace*{0.05\textwidth}%
  \noindent{%
    \raggedright%
    \let \footnote \thanks
      {\LARGE\color{TFBlue}\bfseries \@title \par}%
      \vskip 1.5em%
      \noindent{\large%
        \lineskip .5em%
        \@authorlisttrue%
        \@author
      }%
      \vskip 1em%
%      {\large \@date}%
      {\small \@institutionlist \par}
      \vskip 1em%
    {\small%
    \setlength\fboxsep{10pt}
    \fbox{\parbox[t]{0.68\textwidth}{
      \textcolor{TFBlue}{\textbf{\MakeUppercase{\abstractname}}}\\[0.5ex]
      \@abstract
    }}%
    \hfill%
    \parbox[t]{0.25\textwidth}{\raggedright%
      \textcolor{TFBlue}{\textbf{ARTICLE TYPE}}\\
      \ArticleType\ Article\\[1em]
      \textcolor{TFBlue}{\textbf{ARTICLE HISTORY}}\\
      \@DateReceived\\
      \@DateAccepted\\[1em]
      \textcolor{TFBlue}{\textbf{\MakeUppercase{\keywordsname}}}\\
      \@keywords
  }}}%
  \par
%  \vskip 1.5em}
  \let\thefootnote\relax\footnotetext{\textcolor{TFBlue}{\textbf{CONTACT}}\quad\@CorrPerson\quad\@CorrEmail}
}


\newlength\@hdroffset
  \settoheight\@hdroffset{\fbox{\rule{0pt}{1.8cm}}}
  \addtolength\@hdroffset{-\topskip}


%% title page header/footer
\fancypagestyle{plain}{%
  \fancyhf{} % clear all header and footer fields
  \lhead{\raisebox{-\@hdroffset}[0pt][0pt]{% includes a vertical correction for the title page header
    \shortstack[l]{\MakeUppercase{Letters in Biomathematics} \\[1pt] (URL to be inserted upon acceptance)}%
  }}
  \chead{\color{TFBlue}\raisebox{-\@hdroffset}[0pt][0pt]{\rule[-6pt]{\textwidth}{2pt}}}
  \rhead{\raisebox{-\@hdroffset}[0pt][0pt]{% includes a vertical correction for the title page's header
%    \fbox{\parbox[b][1.8cm][c]{1.4cm}{\small\centering Journal Cover}}%
%    \quad%
%    \fbox{\parbox[b][0.8cm][c]{3.1cm}{\small\centering Taylor \& Francis Logo}}%
  }}
  \renewcommand{\headrulewidth}{0pt}
  \renewcommand{\footrulewidth}{0pt}
%  \fancyhfoffset{0.5in}
}


%% Create the list of institutions
\newif\if@authorlist \@authorlistfalse
\newcommand\inst[1]{\textsuperscript{\if@authorlist\color{TFBlue}\fi#1}}
\newcommand\institution[1]{\gdef\@institutionlist{#1}}

%% Populate the correspondence footnote
\newcommand\correspondence[2]{
  \gdef\@CorrPerson{#1}
  \gdef\@CorrEmail{\texttt{#2}}
}

\newcounter{VolumeNo}
\newcommand\VolumeNo[1]{\setcounter{VolumeNo}{#1}}
\VolumeNo{0}

\newcounter{IssueNo}
\newcommand\IssueNo[1]{\setcounter{IssueNo}{#1}}
\IssueNo{0}

\newcounter{Year}
\newcommand\Year[1]{\setcounter{Year}{#1}}
\Year{0}

\newcommand\DateReceived[1]{\gdef\@DateReceived{#1}}
  \DateReceived{To Be Determined}
\newcommand\DateAccepted[1]{\gdef\@DateAccepted{#1}}
  \DateAccepted{To Be Determined}

%% Some default arguments intended to be show when paper is anonymized
\author{No Authors Listed for Blind Review \\ Do not forget to submit a separate file with author information.}
\institution{List of institutions left blank for blind review}
\correspondence{No Correspondence}{Email}
\authorheading{No Authors Listed}


%%
%% End of file `letinbiom.cls'.
