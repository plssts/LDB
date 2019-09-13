
# Project management screen
def projm_submenu(currentuser)
  cursor = TTY::Cursor
  prompt = TTY::Prompt.new

  loop do
    project_manager = ProjectManager.new
    budget_manager = BudgetManager.new
    print cursor.move_to(0, 3) + cursor.clear_screen_down
    STDOUT.flush
    subchoice = prompt.select('Project actions:',
                                     %w[Set\ budget Negative\ budgets Add\ member Remove\ member
                                        Set\ status Delete\ project Create\ project Back],
                                       cycle: true, per_page: 8)
    case subchoice
    # Refine project's budget
    when 'Set budget'
      proj = prompt.select('', project_manager.list_projects.push('Back'), cycle: true)

      if proj.eql?('Back')
        next
      end
      print Rainbow('Current budget: ').red

      puts budget_manager.budgets_getter(proj.split(':').first)

      choice = prompt.select('', %w[Edit Back], cycle: true)
      if choice.eql?('Edit')

        budget_manager.budgets_setter(proj.split(':').first, prompt.ask('New value: ').to_f)

        prompt.ask(Rainbow('Budget updated.').green, default: '[Enter]')
      end

    # Review projects with negative budget
    when 'Negative budgets'
      puts budget_manager.check_negative

      prompt.select('', %w[Back])

    # Adds a new member to project
    when 'Add member'
      proj = prompt.select('', project_manager.list_projects.push('Back'), cycle: true)

      if proj.eql?('Back')
        next
      end

      project_manager.add_member_to_project(prompt.ask('Member mail:'), proj.split(':').first)

      prompt.ask(Rainbow('New member added.').green, default: '[Enter]')

    # Removes a member from project
    when 'Remove member'
      proj = prompt.select('', project_manager.list_projects.push('Back'), cycle: true)

      if proj.eql?('Back')
        next
      end

      project_manager.remove_member_from_project(prompt.ask('Member mail:'), proj.split(':').first)

      prompt.ask(Rainbow('Member removed.').green, default: '[Enter]')

    # Refine project's status
    when 'Set status'
      proj = prompt.select('', project_manager.list_projects.push('Back'), cycle: true)

      if proj.eql?('Back')
        next
      end

      print Rainbow('Current status: ').red
      puts project_manager.load_project(proj.split(':').first).parm_project_status
      choice = prompt.select('', %w[Edit Back], cycle: true)

      if choice.eql?('Edit')
        if project_manager.set_project_status(proj.split(':').first, prompt.ask('New status: ', default: ' '))
          prompt.ask(Rainbow('Status updated').green, default: '[Enter]')
        else
          prompt.warn('Set status as one of: Proposed, Suspended, Postponed, Cancelled, In progress')
          prompt.ask(Rainbow('Return to previous menu').yellow, default: '[Enter]')
        end
      end

    # Removes a project
    when 'Delete project'
      proj = prompt.select('', project_manager.list_projects.push('Back'), cycle: true)

      if proj.eql?('Back')
        next
      end
      if prompt.yes?(Rainbow('Delete this project? This cannot be undone.').red)

        project_manager.delete_project(Project.new(num: proj.split(':').first))

        prompt.ask(Rainbow('Project deleted.').green, default: '[Enter]')
      end

    # Creates a project
    when 'Create project'
      project_manager.save_project(Project.new(project_name: prompt.ask('Name: '),
                                                  manager: prompt.ask('Manager: '),
                                                  num: id = prompt.ask('Identifier string: ')))
      budget_manager.budgets_setter(id, 0)
      prompt.ask(Rainbow('Project created').green, default: '[Enter]')

    # Return from project management
    when 'Back'
      break
    end
  end
end
