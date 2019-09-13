# frozen_string_literal: true

require 'securerandom' # random hash
require 'uri'

# Defines a User
class User
  def initialize(name: '', last_name: '', email: '', pass: '123')
    @info = { name: name, lname: last_name, email: email,
              pass: pass }
  end

  def data_getter(key)
    @info.fetch(key.to_sym)
  end

  def user_info
    @info
  end

  def to_hash
    { data_getter('email') => { 'name' => data_getter('name'),
                                'lname' => data_getter('lname'),
                                'pwd' => data_getter('pass') } }
  end

  def password_set(new)
    # should later work based on Rails gem 'EmailVeracity' etc.
    @info[:pass] = new
  end

  def mark_logout
    hash = YAML.load_file('online.yml').fetch(@info.fetch(:email))
    start = hash.fetch('start')
    Time.now - start
  end
end
