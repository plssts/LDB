# frozen_string_literal: true

require 'date'
require 'etc'
require './application_record'
srand 0

# rubocop comment?
class Task < ApplicationRecord
  # belongs_to :work_group
end
