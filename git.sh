#!/bin/sh

make distclean
gitcommit=${1}
git add .
git rm -f GPATH 2>/dev/null
git rm -f GRTAGS 2>/dev/null
git rm -f GTAGS 2>/dev/null
git commit -m "${gitcommit}"
git push