#!/bin/bash

texFile=$1

#add header information to make this tex fragment
#a document in its own right

echo '\documentclass[a4paper,oneside]{article}' > c
echo '\usepackage{graphicx}'                    >> c
echo '\usepackage{epsfig}'                      >> c
echo '\begin{document}'                         >> c
echo '\thispagestyle{empty}'                    >> c
cat  $texFile.tex                               >> c

#delete the "end inclusion' command we don't need
sed 's/\\endinput/\\end{document}/g' c > c.tex

latex c.tex
dvips -E -o c.eps  c.dvi
epsbbox.bash c.eps ${texFile}_full.eps



rm c c.* 
