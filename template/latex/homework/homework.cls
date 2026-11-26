%% homework.cls — 作業排版用 class（XeLaTeX）
%%
%% 用法：
%%   \documentclass{homework}               % 圖片 caption 預設隱藏
%%   \documentclass[showcaption]{homework}  % 顯示 caption
%%   其他選項（如 11pt、letterpaper）會傳給 article
\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{homework}[2026/11/24 Homework template]

%---------------------------------------------------------------
% 選項
%---------------------------------------------------------------
\newif\ifhw@showcaption
\hw@showcaptionfalse
\DeclareOption{showcaption}{\hw@showcaptiontrue}
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{article}}
\ProcessOptions\relax
\LoadClass[10pt,a4paper]{article}

%---------------------------------------------------------------
% 基本設定
%---------------------------------------------------------------
\RequirePackage[margin=2.5cm]{geometry}
\RequirePackage[fontset=none]{ctex}    % 中文支援（xelatex）
\setCJKmainfont{Noto Serif CJK TC}
\setCJKsansfont{Noto Sans CJK TC}
\setCJKmonofont{Noto Sans Mono CJK TC}
\ctexset{autoindent=false}             % 段落開頭不縮排
\ctexset{figurename=圖, tablename=表, contentsname=目錄}
\setlength{\parindent}{0pt}
\setlength{\parskip}{0.6em}            % 改用段間距區分段落
% ctex 會把 proof 改成「證明」，這裡改回英文
\AtBeginDocument{\renewcommand{\proofname}{proof:}}
\RequirePackage{amsmath,amssymb,amsthm,mathtools}
\RequirePackage{graphicx}
\RequirePackage{float}                 % 提供 [H]：圖表固定在原位
\RequirePackage{booktabs}
\RequirePackage{enumitem}
\RequirePackage{xcolor}
\RequirePackage{fancyhdr}
\RequirePackage{listings}
\RequirePackage{etoolbox}
\RequirePackage[hidelinks]{hyperref}

\graphicspath{{figure/}}               % 截圖放在 figure/ 資料夾

%---------------------------------------------------------------
% 作業資訊：在 main.tex 用 \title{...}、\subtitle{...} 設定
%---------------------------------------------------------------
\newcommand{\hw@subtitle}{}
\newcommand{\subtitle}[1]{\renewcommand{\hw@subtitle}{#1}}

%---------------------------------------------------------------
% 頁首頁尾
%---------------------------------------------------------------
\pagestyle{fancy}
\fancyhf{}
\renewcommand{\headrulewidth}{0pt}
\cfoot{\thepage}

%---------------------------------------------------------------
% 定理環境
%---------------------------------------------------------------
\newtheorem{lemma}{Lemma}
\newtheorem{claim}{Claim}
\renewcommand{\qedsymbol}{$\blacksquare$}

%---------------------------------------------------------------
% 題目 / 小題
%---------------------------------------------------------------
\newcounter{prob}
% \problem{題目名稱}
\newcommand{\problem}[1]{%
  \refstepcounter{prob}%
  \section*{\large\bfseries \theprob\quad #1\\[-0.6em]\rule{\linewidth}{0.4pt}}%
  \addcontentsline{toc}{section}{\theprob\ #1}%
}
% 小題用 enumerate，標籤為 (1)(2)…
\setlist[enumerate,1]{label=(\arabic*), leftmargin=2em}

% 圖片說明：預設隱藏 figure 裡的 \caption（內容保留不用刪），
% 加上 class 選項 showcaption 即可顯示
\ifhw@showcaption\else
  \AtBeginEnvironment{figure}{\renewcommand{\caption}[2][]{}}
\fi

%---------------------------------------------------------------
% 程式碼排版
%---------------------------------------------------------------
\definecolor{cmt}{rgb}{0.25,0.5,0.25}
\definecolor{kw}{rgb}{0.1,0.1,0.7}
\definecolor{bg}{gray}{0.96}
\lstset{
  basicstyle=\ttfamily\small,
  keywordstyle=\color{kw}\bfseries,
  commentstyle=\color{cmt}\itshape,
  backgroundcolor=\color{bg},
  % 不加行號，複製程式碼時才不會連數字一起選到
  % 個別區塊需要時可用 \begin{lstlisting}[numbers=left]
  numbers=none, numberstyle=\tiny\color{gray},
  breaklines=true, frame=single, framerule=0.2pt,
  showstringspaces=false, tabsize=4,
  columns=fullflexible, keepspaces=true,
  extendedchars=true, inputencoding=utf8,
}

%---------------------------------------------------------------
% 標題（精簡版）：在 \begin{document} 後呼叫 \maketitle
%---------------------------------------------------------------
\renewcommand{\maketitle}{%
  \begin{center}
    {\LARGE\bfseries \@title}%
    \ifx\hw@subtitle\@empty\else\\[2pt]{\normalsize \hw@subtitle}\fi
  \end{center}
  \vspace{-0.5em}
  \thispagestyle{fancy}
}

\endinput
