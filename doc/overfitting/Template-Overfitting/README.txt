The "letinbiom" document class takes the option
"research", "education", or "review".
Use the one that applies to your type of article.

Within the \author argument, you should use the \inst{}
command that puts the desired index for each author's
institution and places it in superscript. Also, do not use
the \and command to separate the authors' names.

The \institution{} command is used to list the author's
affiliations. Use the \inst{} command here as in the
\author{} command's argument.

The \correspondance command takes a two arguments:
the first indicates the corresponding author's name,
the second indicates the corresponding author's email.

Use the \keywords command to list no more than 5 keywords.

The \abstract command replaces the abstract environment.
(DO NOT USE \beginabstract \endabstract).
This command must appear in the source file BEFORE the
\maketitle command, preferably in the preamble.

Use the \authorheading command to give a shortened list
of authors to appear in the header of even-numbered pages.
If the list is still too long to fit in the header, consider
giving something akin to \authorheading{I.\,M.~Surname et al.}

This document class requires the following packages in order
to compile: 

{geometry}
{fancyhdr}
{color}
{lineno}

(See ctan.org to download these packages if you do not already have them).
