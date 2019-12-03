\NeedsTeXFormat{LaTeX2e}[1995/12/01]
\ProvidesClass{deltares_manual}
              [2007/10/31 v1.0 Standard LaTeX document class]
\DeclareOption{onecolumn}{\OptionNotUsed}
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{report}}
\ProcessOptions\relax
\LoadClass[11pt,twoside,openright,a4paper,titlepage]{report}
%
% Change to Times font
%
%\usepackage{mathptmx}

%
% Change to Palatino font
%
%\usepackage{mathpazo}

%
% Change to Helvetica font
%
%\usepackage{hvmaths} % commercial
%
%\usepackage[scaled=.92]{helvet}
%\def\rmdefault{phv}
%
% Declaring the letters as OML/phv/m/it does not change the font.
% However, upon changing it to OT1/phv/m/it characters such as
% <, > and greek characters are lost.
%
%%\DeclareSymbolFont{letters}     {OML}{phv}{m}{it}
%\DeclareSymbolFont{letters}     {OT1}{phv}{m}{it}
%
%\DeclareSymbolFont{operators}   {OT1}{phv}{m}{n}
%\DeclareSymbolFont{symbols}     {OMS}{phv}{m}{n}
%\DeclareSymbolFont{largesymbols}{OMX}{phv}{m}{n}
%\DeclareSymbolFont{bold}        {OT1}{phv}{bx}{n}
%\DeclareSymbolFont{italic}      {OT1}{phv}{m}{it}
%\renewcommand{\familydefault}{phv}

%\usepackage[dvips]{graphicx}
\usepackage[pdftex]{graphicx}
\usepackage{epstopdf}
\usepackage{color}
%\usepackage{frcursive} % needed for 'write' letter (French Cursive), use in processes library
\usepackage{float} % needed to force the location of figures \begin{figure}[H]

%\def\backref{Cited on page }

\usepackage{svn-multi}
\usepackage{tabularx}
\usepackage{longtable}
\usepackage{verbatim}
\usepackage{calc}
\usepackage{wrapfig}
\usepackage{caption}
\usepackage{url}
\usepackage{moreverb}

\usepackage{amstext} % for \text command in math environment
%

% to align equations left add [fleqn] as option to amsmath
%
\usepackage[fleqn]{amsmath}
\usepackage{amssymb}

%\usepackage[pagebackref,pdfborder=0 0 0,dvipdfm]{hyperref}
\usepackage[pagebackref,pdfborder=0 0 0,bookmarksnumbered=true,bookmarks=true,pdfpagelayout=TwoPageRight]{hyperref}
%------------------------------------------------------------------------------

\hoffset -1in \voffset -1in

\topmargin 1.5cm
\headheight 1cm
\headsep \baselineskip
\setlength{\textheight}{29.7cm-5cm-\baselineskip}
\footskip 1cm
% 1.5cm remaining

\oddsidemargin 3.5cm
\setlength{\textwidth}{21cm-5.5cm}
\marginparsep 0mm
\marginparwidth 0mm
\evensidemargin 2cm

%C5 paper format (formaat van envelope voor dubbel gevouwen A4; en user manaul MSheet)

%\setlength\paperheight{229mm}
%\setlength\paperwidth{162mm}
%\setlength{\textheight}{229mm-5cm-\baselineskip}
%\setlength{\textwidth}{162mm-5.5cm}


%------------------------------------------------------------------------------
%
% newcommand for tableofcontents, listoffigures, listotables; taken from report.sty and macro MakeUppercase removed
% 4 nov 2008 Jan Mooiman
%
\renewcommand\tableofcontents{%
    \if@twocolumn
      \@restonecoltrue\onecolumn
    \else
      \@restonecolfalse
    \fi
    \chapter*{\contentsname
        \@mkboth{%
           \contentsname}{\contentsname}}%
    \@starttoc{toc}%
    \if@restonecol\twocolumn\fi
    }
\renewcommand\listoffigures{%
    \if@twocolumn
      \@restonecoltrue\onecolumn
    \else
      \@restonecolfalse
    \fi
    \chapter*{\listfigurename}%
      \@mkboth{\listfigurename}%
              {\listfigurename}%
    \@starttoc{lof}%
    \if@restonecol\twocolumn\fi
    }
\renewcommand\listoftables{%
    \if@twocolumn
      \@restonecoltrue\onecolumn
    \else
      \@restonecolfalse
    \fi
    \chapter*{\listtablename}%
      \@mkboth{%
          \listtablename}%
         {\listtablename}%
    \@starttoc{lot}%
    \if@restonecol\twocolumn\fi
    }


\newif\if@draft
\if@draft
  \def\draftname{Draft}%
\else
  \def\draftname{}
\fi
\def\ds@draft{\overfullrule 5pt \@drafttrue}

\newcommand{\monthname}{%
\ifcase\month\or January\or February%
\or March\or April\or May%
\or June\or July\or August%
\or September\or October\or November%
\or December\fi}%

\raggedbottom


\def\program#1{\gdef\@program{#1}}
\def\subtitle#1{\gdef\@subtitle{#1}}
\def\manualtype#1{\gdef\@manualtype{#1}}
\def\revision#1{\gdef\@revision{#1}}
\def\@program{Program}
\def\@subtitle{Subtitle}
\def\@manualtype{Manual}
\def\@revision{000}

\author{Revision: \@revision}

% \title{\@program\\\@subtitle\\\@manualtype}
\newcommand{\thechap}{$\;$\leftmark{}$\;$}

%------------------------------------------------------------------------------

\def\scriptsize{\@setsize\scriptsize{9.5pt}\viiipt\@viiipt}
\def\tiny{\@setsize\tiny{7pt}\vipt\@vipt}
\def\large{\@setsize\large{14pt}\xiipt\@xiipt}
\def\Large{\@setsize\Large{18pt}\xivpt\@xivpt}
\def\LARGE{\@setsize\LARGE{22pt}\xviipt\@xviipt}
\def\huge{\@setsize\huge{25pt}\xxpt\@xxpt}
\def\Huge{\@setsize\Huge{30pt}\xxvpt\@xxvpt}
\def\HUGE{\@setsize\Huge{40pt}\xxvpt\@xxvpt}

\def\program#1{\gdef\@program{\selectfont #1}}
\def\title#1{\gdef\@title{\selectfont #1}}
\def\subtitle#1{\gdef\@subtitle{\selectfont #1}}
\def\author#1{\gdef\@author{\selectfont #1}}
\def\reporttype#1{\gdef\@reporttype{\selectfont #1}}
\def\reportdate#1{\gdef\@reportdate{\selectfont #1}}

%\def\program#1{\gdef\@program{\fontfamily{phv}\selectfont #1}}
%\def\title#1{\gdef\@title{\fontfamily{phv}\selectfont #1}}
%\def\subtitle#1{\gdef\@subtitle{\fontfamily{phv}\selectfont #1}}
%\def\author#1{\gdef\@author{\fontfamily{phv}\selectfont #1}}
%\def\reporttype#1{\gdef\@reporttype{\fontfamily{phv}\selectfont #1}}
%\def\reportdate#1{\gdef\@reportdate{\fontfamily{phv}\selectfont #1}}

%------------------------------------------------------------------------------

\def\maketitle{
\newpage
\thispagestyle{empty}
\setcounter{page}{1}

\hspace*{80pt}{\LARGE\bf \draftname}

\vskip 200pt plus \z@ minus \z@
\hangindent 80pt \hspace*{80pt}{\HUGE\bf \@program \par}
\vfil\vfil
\hangindent 80pt \hspace*{80pt}{\baselineskip 14pt \Large\bf \@subtitle \par}
\vfil
\hangindent 80pt \hspace*{80pt}{\Large\bf \@manualtype \par}
\vfil\vfil\vfil
\hangindent 80pt \hspace*{80pt}{\@author \par}
\vfil
%\hangindent 80pt \hspace*{80pt}{\monthname,\space\number\year \par}
\hangindent 80pt \hspace*{80pt}{\today \par}
\vfil

\if@draft
      \special{!userdict gsave 200 70 translate
      65 rotate /Times-Roman findfont 216 scalefont setfont
      0 0 moveto 0.95 setgray (DRAFT) show grestore}
\fi

\clearpage

\gdef\@author{}\gdef\@title{}\gdef\@subtitle{}
\let\maketitle\relax}

%------------------------------------------------------------------------------

\newcommand{\manualtitle}{%
\pagenumbering{roman}%
\maketitle%
\pagestyle{empty}%
\textbf{\@manualtype\space\@program}

\vskip 1cm
\vfill\vfill\vfill
Published and printed by:\\~\\
Deltares\\
Rotterdamseweg 185\\
p.o. box 177\\
2600 MH Delft\\
The Netherlands
\begin{tabbing}
telephone: \=  +31 88 335 85 85\\
fax:       \>  +31 88 335 85 82\\
e-mail:    \>  info@deltares.nl\\
www:       \>  \url{http://www.deltares.nl}
\end{tabbing}

\vskip 1cm
For support contact:
\begin{tabbing}
telephone: \= +31 88 335 85 55 \\
fax:       \> +31 88 335 81 11 \\
e-mail:    \> xbeach@deltares.nl\\
www:       \> \url{http://www.xbeach.org/}
\end{tabbing}

\vskip 1cm
Copyright {\copyright} \number\year~Deltares\\
All rights reserved. No part of this document may be reproduced in any form by print, photo
print, photo copy, microfilm or any other means, without written permission from the
publisher: Deltares.
\newpage%
\pagestyle{fancy}%
\tableofcontents%
\cleardoublepage%
\pagenumbering{arabic}%
}%

%------------------------------------------------------------------------------
%
% Change header and footer
%
\usepackage{fancyhdr}
\newcommand{\headerfont}{\fontsize{8}{10}\selectfont}
\pagestyle{fancy}
\renewcommand{\chaptermark}[1]{\markboth{#1}{}}
\fancyhead{}
\fancyhead[LO,RE]{\headerfont \@program\\\@manualtype}
\fancyhead[CO,CE]{\headerfont \thechap\\}
\fancyhead[RO,LE]{\headerfont \monthname\space\number\year\\\@revision}
\fancyfoot{}
\fancyfoot[LO,RE]{\headerfont Deltares}
\fancyfoot[CO,CE]{}
\fancyfoot[RO,LE]{\headerfont \thepage}

\fancypagestyle{plain}{%
\fancyhead{}%
\fancyhead[LO,RE]{\headerfont \@program\\\@manualtype}%
\fancyhead[CO,CE]{\headerfont \thechap\\}%
\fancyhead[RO,LE]{\headerfont \monthname\space\number\year\\\@revision}%
\fancyfoot{}%
\fancyfoot[LO,RE]{\headerfont Deltares}%
\fancyfoot[CO,CE]{}%
\fancyfoot[RO,LE]{\headerfont \thepage}}

\addtocounter{secnumdepth}{1}
\setlength{\parskip}{\baselineskip/2}
\setlength{\parindent}{0pt}
\setlength{\parsep}{1pt}
\setlength{\partopsep}{1pt}

%------------------------------------------------------------------------------
%
% To change the caption of tables and figures.
% Format is defautl or `hang' wich aligns caption to the right of the figure statement
\captionsetup{format=default,margin=0.9cm,font=small,labelfont=sl,textfont=sl}
%
%------------------------------------------------------------------------------
%
% Simple remark environment that always writes Remarks.
%
%\newenvironment{remark}%
%  {{\bf Remarks:}\setlength{\parskip}{0pt}%
%  \begin{itemize}{}{}}
%  {\end{itemize}}
%
%------------------------------------------------------------------------------
%
% Define a more advanced remark environment that writes Remark if there is only
% one item and that writes Remarks if there are multiple items.
%
\usepackage{ifthen}
%
\newcounter{n_sp_blocks}
\newcounter{n_sp_items}
\newenvironment{singleplural}[2]%
  {\addtocounter{n_sp_blocks}{1}%
   \ifthenelse{\equal{a\ref{sp_block\arabic{n_sp_blocks}}}{a1}}%
     {\textbf{#1:}}%
     {\textbf{#2:}}%
   \setlength{\parskip}{0pt}%
   \begin{list}{$\m@th\bullet$}{\usecounter{n_sp_items}}}
  {\label{sp_block\arabic{n_sp_blocks}}\end{list}}
%
\newenvironment{Remark}%
  {\begin{singleplural}{Remark}{Remarks}}
  {\end{singleplural}}
%
\newenvironment{Restriction}%
  {\begin{singleplural}{Restriction}{Restrictions}}
  {\end{singleplural}}
%
\newenvironment{Warning}%
%  {\color{red}\begin{singleplural}{Warning}{Warnings}}
  {\begin{singleplural}{Warning}{Warnings}}
  {\end{singleplural}}
%
%------------------------------------------------------------------------------

\newenvironment{guilist}%
  {\begin{list}{}%
    {%
      \renewcommand{\makelabel}[1]%
        {\raisebox{0pt}[1ex][0pt]{\makebox[\labelwidth][l]%
          {\parbox[t]{\labelwidth}{\raggedright\hspace{0pt}##1}}}}%
      \setlength{\labelwidth}{3.7cm}%
      \setlength{\leftmargin}{\labelwidth+\labelsep}%
    }%
  }%
  {\end{list}}

\newenvironment{domain} % Added more spacing around the text in the header, 19/11/2008 RMC Spiteri
  {\textbf{Domain:}

   \small\begin{tabular}{|p{4.8cm}|p{2.4cm}|p{2.4cm}|p{2.4cm}|p{\textwidth-60pt-12cm}|} \hline  \STRUT
   \textbf{Parameter} & \textbf{Lower limit} & \textbf{Upper limit} & \textbf{Default} & \textbf{Unit} \\[1ex] \hline
   }
  {\end{tabular}}

\newenvironment{action}%
%  {\color{green}\begin{itemize}}%
  {\begin{itemize}}%
  {\end{itemize}}
%
%                             definition of varlist environment for listing
%                               variables and their meaning after a formula
%
%  X   : description
%  Y_n : description
%
\newcommand{\varlistcolon}{} % originally :
\newenvironment{varlist}%
  {\begin{list}{}{%
    \renewcommand{\makelabel}[1]{\quad{##1}\hfill\varlistcolon}%
    \setlength{\labelwidth}{3.7cm}% Changed to 3.7cm, 19/11/2008 RMC Spiteri
    \setlength{\leftmargin}{\labelwidth+\labelsep}%
    \setlength{\parsep}{0pt}%
    \setlength{\itemsep}{0pt}}}
  {\end{list}}

%------------------------------------------------------------------------------

\newenvironment{symbollist}%
  {\begin{list}{}{%
    \renewcommand{\makelabel}[1]{\quad{##1}\hfill\varlistcolon}%
    \setlength{\labelwidth}{2.0cm}
    \setlength{\leftmargin}{\labelwidth+\labelsep}%
    \setlength{\parsep}{0pt}%
    \setlength{\itemsep}{0pt}}}
  {\end{list}}

%------------------------------------------------------------------------------

\newenvironment{options}%
  {\underline{Options:}
  \begin{list}{}%
    {%
      \renewcommand{\makelabel}[1]%
        {\raisebox{0pt}[1ex][0pt]{\makebox[\labelwidth][l]%
        {\parbox[t]{\labelwidth}{\raggedright\hspace{0pt}##1}}}}%
      \setlength{\labelwidth}{3.7cm}%
      \setlength{\leftmargin}{\labelwidth+\labelsep}%
    }%
  }%
  {\end{list}}

%------------------------------------------------------------------------------

\def\nonumchapter#1{%
    \chapter*{#1}%
    \addcontentsline{toc}{chapter}{#1}%
    \markboth{#1}{}}

%------------------------------------------------------------------------------


\newcommand{\clearemptydoublepage}{\newpage{\pagestyle{empty}\cleardoublepage}}
\newcommand{\STRUT}{\rule{0in}{3ex}}

\newcommand{\Deltares}{Deltares}
\newcommand{\WL}{{WL\,$|$\,Delft Hydraulics}}
\newcommand{\degr}{\ensuremath{^\circ}}
\newcommand{\tenlog}{ \ensuremath{\ {}^{10}\!\log} }

\newcommand{\window}[1]{\textbf{#1}}
\newcommand{\menu}[1]{\textit{#1}}
\newcommand{\button}[1]{\textit{#1}}
\newcommand{\file}[1]{$<$#1$>$}
\newcommand{\dir}[1]{$<$#1$>$}
\newcommand{\ginput}[1]{``#1''}
\newcommand{\command}[1]{{\normalfont\ttfamily #1}}
\newcommand{\block}[1]{\textbf{\rmfamily #1}}
\newcommand{\keyw}[1]{{\normalfont\ttfamily #1}}
\newcommand{\unit}[1]{[#1]}
\newcommand{\ext}[1]{$<$#1$>$}
\newcommand{\key}[1]{\texttt{#1}}
\newcommand{\function}[1]{\textit{#1}}

\newcommand{\option}[1]{\vspace{0.5cm}\underline{#1}}  % Geeft een optie aan, vooral gebruikt in WAQ TRM

%% Referencing
\newcommand{\Cref}[1]{Chapter~\ref{#1}}
\newcommand{\Sref}[1]{Section~\ref{#1}}
\newcommand{\Fref}[1]{Figure~\ref{#1}}
\newcommand{\Aref}[1]{Algorithm~\ref{#1}}
\newcommand{\Tref}[1]{Table~\ref{#1}}
\newcommand{\Eref}[1]{Equation~\ref{#1}}


\hyphenation{bathy-metry}

\renewcommand\paragraph{\@startsection{paragraph}{4}{\z@}%
                                     {-3.25ex\@plus -1ex \@minus -.2ex}%
                                     {1pt}%
                                     {\normalfont\normalsize\bfseries}}

%\def\promille{\leavevmode\kern-.05em
%\raise.5ex\hbox{\the\scriptfont0 0}\kern-.15em/\kern-.15em
%\lower.25ex\hbox{\the\scriptfont0 00}}

\newcommand{\promille}{%
  \relax\ifmmode\promillezeichen
        \else\leavevmode\(\mathsurround=0pt\promillezeichen\)\fi}
\newcommand{\promillezeichen}{%
  \kern-.05em%
  \raise.5ex\hbox{\the\scriptfont0 0}%
  \kern-.15em/\kern-.15em%
  \lower.25ex\hbox{\the\scriptfont0 00}}


%------------------------------------------------------------------------------

\newcommand{\perscomm}[1]{\citetext{#1, pers.\ comm.}}
\usepackage{natbib}
\bibpunct[, ]{(}{)}{;}{a}{,}{,}
\renewcommand\bibsection{}
%\bibliographystyle{../common/deltares_chicago_like}
%\usepackage{chapterbib}
