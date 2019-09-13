
# User management screen
def userm_submenu(currentuser)
  cursor = TTY::Cursor
  prompt = TTY::Prompt.new

  loop do
    user_manager = UserManager.new
    print cursor.move_to(0, 3) + cursor.clear_screen_down
    STDOUT.flush
    subchoice = prompt.select('User actions:', %w[Change\ password Delete\ current\ user
                                                           Back], cycle: true)
    case subchoice
    # Change user password
    when 'Change password'
      user_manager.save_user_password(currentuser, prompt.mask("New password:"))

    # Delete this user
    when 'Delete current user'
      if prompt.yes?(Rainbow('Delete this user? This cannot be undone.').red)

        user_manager.delete_user(User.new(email: currentuser))

        prompt.ask(Rainbow('User deleted.').green, default: '[Enter]')
      end

    # Return from user management
    when 'Back'
      break
    end
  end
end
