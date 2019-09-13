# frozen_string_literal: true

require_relative 'project_manager'
require 'yaml'

# Defines user management
class UserManager
  def initialize
    load_file
    @users = {} if @users.equal?(false)
    @current_user = {}
  end

  def load_file
    @users = YAML.load_file('users.yml')
  end

  def current_user_getter
    @current_user
  end

  def users_getter
    @users
  end

  def to_hash(email)
    return false unless @users.key?(email)

    { email => @users.fetch(email) }
  end

  def register(user)
    @current_user = user.user_info

    mailing = @current_user.fetch('email'.to_sym)
    hash = { mailing => { 'name' => @current_user.fetch('name'.to_sym),
                          'lname' => @current_user.fetch('lname'.to_sym),
                          'pwd' => @current_user.fetch('pass'.to_sym) } }
    return true if users_push(mailing, hash)

    false
  end

  def mark_login(email)
    return false unless (@current_user = email).instance_of?(String)

    hash = { @current_user => { 'start' => Time.now, 'end' => 0 } }
    File.open('online.yml', 'w') do |fl|
      fl.write hash.to_yaml.sub('---', '')
    end
    true
  end

  def login(email, password)
    hsh = @users[email]
    return false if [nil].include?(hsh)
    return false unless hsh.fetch('pwd').eql?(password)

    mark_login(email)
  end

  def delete_user(user)
    users_pop(user.data_getter('email'))
  end

  def users_push(eml, hash)
    return false unless eml.instance_of?(String) && [nil].include?(@users[eml])

    File.open('users.yml', 'a') do |fl|
      fl.write hash.to_yaml.sub('---', '')
    end

    load_file
    true
  end

  def users_pop(email)
    return false if [nil].include?(@users[email])

    @users.delete(email)
    File.open('users.yml', 'w') do |fl|
      fl.write @users.to_yaml.sub('---', '').sub('{}', '')
    end
    true
  end

  def save_user_password(user_email, password)
    return false if [nil].include?(password) || !@users.key?(user_email)

    hsh = to_hash(user_email).fetch(user_email)

    usr = User.new(name: hsh.fetch('name'),
                   last_name: hsh.fetch('lname'),
                   email: user_email,
                   pass: password)

    true if users_pop(user_email) && users_push(user_email, usr.to_hash)
  end
end
