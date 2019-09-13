# frozen_string_literal: true

require 'date'
require 'etc'
require './application_record'
srand 0

# rubocop comment?
class WorkGroupTask < ApplicationRecord
  # belongs_to :workgroups
end
