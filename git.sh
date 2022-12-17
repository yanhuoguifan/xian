#!/bin/sh

make distclean
gitcommit = $1
git add .
git rm -f GPATH
git rm -f GRTAGS
git rm -f GTAGS
git commit -m "$gitcommit"
git push