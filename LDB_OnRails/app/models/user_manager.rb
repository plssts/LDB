# frozen_string_literal: true

require_relative 'user'
require './application_record'
require 'yaml'

# class defining user management
class UserManager
  def initialize
    @state = true
  end

  def stater(arg = @state)
    @state = arg
  end

  def register(nm_lnm, email, pass)
    spare = nm_lnm
    user = User.find_by(email: email)
    return false if user

    User.create(name: nm_lnm.fetch(0), lname: spare.fetch(1),
                email: email, pass: pass)

    @state
  end

  def login(email, pass)
    usr = User.find_by(email: email)
    return false if [nil].include?(usr)
    return false unless usr.pass.eql?(pass) && @state

    true
  end

  def delete_user(email)
    user = User.find_by(email: email)
    return false unless user && !manages_project?(email)

    user.destroy
    true
  end

  def upl_certif(url, user)
    return false unless valid_url(url)

    Certificate.create(user: user, link: url)
  end

  def valid_url(url)
    ext = File.extname(URI.parse(url).path)
    valid = %w[.doc .pdf]
    return true if valid.include?(ext) && @state

    false
  end

  def manages_project?(user_email)
    proj = Project.find_by(manager: user_email)
    return true if proj && @state

    false
  end
end
