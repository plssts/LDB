# frozen_string_literal: true

# handles users
class UsersController < ApplicationController
  def create
    return unless params.key?(:user)

    @hash = params.fetch(:user)
    UserManager.new.register([@hash.fetch(:name),
                              @hash.fetch(:lname)],
                             @hash.fetch(:email),
                             @hash.fetch(:pass))
  end

  def show
    # renders after deleting user
  end

  def update
    @hash = params.fetch(:user)
    usr = User.find_by(email: current_user['email'])
    usr.name = @hash.fetch(:name)
    usr.lname = @hash.fetch(:lname)
    usr.password_set(@hash.fetch(:pass))
  end

  def destroy
    UserManager.new.delete_user(current_user['email'])
  end

  def find_and_login
    @user = User.find_by(email: params.fetch(:user).fetch(:email))
    if @user
      sign_in(@user)
      return true
    end
    false
  end

  def parse_login
    usr = params.fetch(:user)
    result = UserManager.new.login(usr.fetch(:email), usr.fetch(:pass))
    return unless result

    false unless find_and_login
  end
end
