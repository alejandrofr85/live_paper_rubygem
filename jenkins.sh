#!/bin/bash

echo; cat $0 | sed -e 's:^:  |:'; echo # show this script in the build log

set -e # automatic exit if any command fails

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"
PATH=$PATH:$HOME/.rvm/bin # Add RVM to PATH for scripting

#rvm install $(cat .ruby-version)
#rvm use     $(cat .ruby-version)

bundle install
export CODECLIMATE_REPO_TOKEN=bf202b8f2001e72364ea81718998d383516ee09d8f2b75b728d11f5fa28b3e81
rake spec
autotag create ci