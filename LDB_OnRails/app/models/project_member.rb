# frozen_string_literal: true

require 'date'
require 'etc'
require './application_record'
srand 0

# rubocop comment?
class ProjectMember < ApplicationRecord
  # belongs_to :projects
end
