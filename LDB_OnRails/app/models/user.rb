# frozen_string_literal: true

require 'securerandom' # random hash kuriantis metodas yra
require 'uri'
require './application_record'
require 'mail'

# Documentation about class User
class User < ApplicationRecord
  devise :database_authenticatable
  validates :email, presence: true
  has_many :notes_managers
  has_many :certificates

  before_save do
    throw :abort unless self.class.pass_secure(pass)
  end

  def password_set(new)
    # should later (5 laboras) work based on Rails gem 'EmailVeracity'
    return false unless self.class.pass_secure(new)

    self.pass = new
    save
    true
  end

  def self.pass_secure(passw)
    if passw.match?(/\d/)
      return true unless [nil].include?(
        passw.index(/[\+\-\!\@\#\$\%\^\&\*\(\)]/)
      )
    end
    false
  end
end
