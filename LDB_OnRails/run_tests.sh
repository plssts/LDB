#!/bin/bash
bundle install

echo 'RSpec...'
# sleep 2
bundle exec rspec

# sleep 5
echo 'Reek...'
# sleep 2
reek -c .reek.yml

# sleep 5
echo 'Rubocop...'
# sleep 2
rubocop

# sleep 5
echo 'Mutant...'
# sleep 2

# Models: BudgetManager NotesManager Notification Order Project ProjectManager ProjectMember ProvidedMaterial Provider Search User UserManager WorkGroup WorkGroupManager WorkGroupMember WorkGroupTask Certificate Graph Task || Controllers: OrdersController MaterialsController ProjectsController ProjmemsController SearchController TasksController UsersController WelcomeController WgsController ->this gets stuck for ~60s on #destroy, so no worries. Same with OrdersController#destroy.

bundle exec mutant --include app --use rspec BudgetManager NotesManager Notification Order Project ProjectManager ProjectMember ProvidedMaterial Provider Search User UserManager WorkGroup WorkGroupManager WorkGroupMember WorkGroupTask Certificate Graph Task OrdersController MaterialsController ProjectsController ProjmemsController SearchController TasksController UsersController WelcomeController WgsController -j 1
