#!/bin/bash -e

# check for needed tools
for i in python wget pandoc iconv sed grep date basename xelatex; do
 if [ -z "$(which $i)" ]; then
  echo "error: ${i} not installed"
  exit 1
 fi
done

url="https://paulgraham.com"

mkdir -p html
if [ ! -e articles.html ]; then
  wget ${url}/articles.html
fi

python articles.py > articles
 
for i in $(cat articles | cut -d" " -f1); do
  echo ${i}
  if [ ! -e html/${i} ]; then
    wget -c ${url}/${i} -O html/${i}
  fi
done


rm -f essays
mkdir -p md

# for i in html/progbot.html; do
for i in html/*.html; do
 name=$(basename "${i}" .html)
 out=md/${name}.md
 title=$(grep -w ${name}.html articles | cut -d" " -f2- | tr -d \")
 date=$(iconv -f latin1 -t utf8 ${i} | python parsehtml.py | sed 's/<br\/><br\/>/<p>\n/g' |
 sed 's/<font [^>]*>//g' | grep -oE '(January|February|March|April|May|June|July|August|September|October|November|December) 20[0-9][0-9]' ${i} | head -n1)
 if [ ! -z "${date}" ]; then
   yearmonth=$(date --date "1 ${date}" +"%Y-%m")
 else
   yearmonth=1969-01
 fi
 out=md/${yearmonth}-${name}.md
 
 echo ${out} | tee -a essays
 cat << EOF > ${out} 
---
title: "${title}"
author: Paul Graham
date: ${date}
lang: en-US
fontsize: 10pt
mainfont: TeX Gyre Pagella
papersize: a5
...

EOF

 iconv -f latin1 -t utf8 ${i} | python parsehtml.py |  \
 sed 's/<br\/><br\/>/<p>\n/g' | \
 sed 's/<font [^>]*>//g' | \
 sed 's/<\/font>//g' | \
 sed 's/<td .*>//' | \
 sed 's/<\/td>//' | \
 sed 's/<center>\* \* \*<\/center>/\n<hr>\n/g' | \
 sed 's/xmp/pre/g' | \
 sed 's/``/“/g' | sed "s/''/”/g" | \
 sed 's/<u>//g' | sed 's/<\/u>//g' | \
 pandoc -f html --title="${title}" --lua-filter=images.lua --lua-filter=bold.lua -t markdown |  sed 's/<p>/\n/' >> ${out}
done

#  sed 's/<b>/<strong>/g' | sed 's/<\/b>/<\/strong>/g' | \



cat << EOF > essays.md
---
title: Essays
date: Updated $(date -r articles.html "+%A %-d %B %Y")
author: Paul Graham
lang: en-US
documentclass: book
classoption:
 - oneside
geometry:
 - a5paper
 - top=26mm
 - bindingoffset=0mm
 - left=18mm
 - right=18mm
 - bottom=18mm
fontsize: 10pt
mainfont: TeX Gyre Pagella
toc: true
secnumdepth: 1
number-sections: true
...
EOF

sort essays > essays-sorted
for i in $(cat essays-sorted); do
  title=$(grep title: ${i} | head -n1 | cut -d\" -f2)
  date=$(grep date: ${i} | head -n1 | cut -d: -f2)
  echo $i, $title, $date
cat << EOF >> essays.md  

# ${title}

EOF
  pandoc ${i} -t markdown >> essays.md
done

pandoc essays.md --number-sections --toc -s -o essays.epub
pandoc essays.md --number-sections -s -o essays.tex --pdf-engine=xelatex
pandoc essays.md --number-sections -s -o essays.pdf --pdf-engine=xelatex
