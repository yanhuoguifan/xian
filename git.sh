#!/bin/sh

make distclean
gitcommit=${1}
git add .
git commit -m "${gitcommit}" -s
git push