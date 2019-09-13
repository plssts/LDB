#!/bin/bash
bundle install

cd spec
echo 'RSpec...'
rspec *spec.rb
cd ..

echo 'Reek...'
reek -c .reek.yml

echo 'Rubocop...'
rubocop

echo 'Mutant...'
# Classes: Project ProjectManager User UserManager WorkGroup WorkGroupManager BudgetManager NotesManager Search

bundle exec mutant --include lib --use rspec Project ProjectManager User UserManager WorkGroup WorkGroupManager BudgetManager NotesManager Search -j 1
