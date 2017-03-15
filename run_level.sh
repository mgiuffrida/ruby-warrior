#!/bin/sh

level=$(head -n 1 rubywarrior/README | sed 's/Level\s//')

cp  "player${level}.rb" rubywarrior/player.rb

git add "player${level}.rb"
git add rubywarrior/.profile
git add rubywarrior/README

cd rubywarrior
echo y | rubywarrior -t 0 > "../level${level}.out"
cd ../
git add "level${level}.out"
