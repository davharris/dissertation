# bibtex ids with colons in them (eg R package names) don't work. Remove the pattern :_
sed -i "" "s/:_/_/g" My\ Library.bib

pandoc -o dissertation.pdf --bibliography=My\ Library.bib --csl=ecology.csl -V geometry:margin=1in -V linestretch=2 -V fontsize=12pt dissertation.md

open dissertation.pdf
