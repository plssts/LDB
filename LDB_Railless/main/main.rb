# frozen_string_literal: true

require 'rainbow'
require 'tty/cursor'
require 'tty/prompt'
require 'time'
require_relative '../lib/user'
require_relative '../lib/user_manager'
require_relative '../lib/notes_manager'
require_relative '../lib/project_manager'
require_relative '../lib/budget_manager'
require_relative '../lib/work_group_manager'
require_relative '../lib/search'
require_relative 'submenus/notes_submenu'
require_relative 'submenus/projectm_submenu'
require_relative 'submenus/src_submenu'
require_relative 'submenus/userm_submenu'
require_relative 'submenus/wgm_submenu'

$cursor = TTY::Cursor
$prompt = TTY::Prompt.new
$usr_hash = { 'Search' => method(:src_submenu),
              'Notes' => method(:notes_submenu),
              'User management' => method(:userm_submenu),
              'Project management' => method(:projm_submenu),
              'Work group management' => method(:wgm_submenu) }

# Modules menu screen
def user_menu(currentuser)
  loop do
    puts $cursor.clear_screen + $cursor.move_to(0, 0)
    puts Rainbow("LDB\t").green + Rainbow("--[#{currentuser}]--\t").cyan + Rainbow("[ #{Date.today} ]").green

    choice = $prompt.select('Modules:', %w[Search Notes User\ management Project\ management
                                          Work\ group\ management Quit], cycle: true)
    break if choice.eql?('Quit')
    $usr_hash[choice].call(currentuser)
  end
  puts Rainbow("Logging off.").yellow + "\nSpent " + User.new(email: currentuser).mark_logout.to_s + " s online."
  sleep(3)
end

# Initial screen
loop do
  user_manager = UserManager.new
  puts $cursor.clear_screen
  puts $cursor.move_to(0, 0)
  puts Rainbow("LDB\t").bright + Rainbow('[' + Date.today.to_s + ']').green

  choice = $prompt.select('', %w[Sign\ up Login Exit], cycle: true)
  puts $cursor.clear_lines(2, :up)

  case choice
  # Create a new user
  when 'Sign up'
    puts $cursor.clear_screen
    if (user_manager.register(
        User.new(email: $prompt.ask('Email:'), pass: $prompt.mask('Password:'))))
      $prompt.ask(Rainbow('User created successfully. You may now login').green, default: '[Enter]')
    else
      $prompt.warn('Could not create a new account')
      $prompt.ask(Rainbow('Return to previous menu').yellow, default: '[Enter]')
    end

  # Login with existing credentials
  when 'Login'
    puts $cursor.clear_screen

    email = $prompt.ask('Email:')
    pass = $prompt.mask('Password:')

    if user_manager.login(email, pass)
      user_menu(email)
    else
      $prompt.warn('Could not login with specified credentials')
      $prompt.ask(Rainbow('Return to previous menu').yellow, default: '[Enter]')
    end

  # Terminate LDB
  when 'Exit'
    puts $cursor.clear_screen
    break
  end
end
