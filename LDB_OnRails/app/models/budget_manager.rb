# frozen_string_literal: true

require 'date'
require 'etc'
require_relative 'project'
require './application_record'
require 'yaml'

# Manages financial information about projects
class BudgetManager
  def initialize
    @state = true
  end

  def stater(val = @state)
    @state = val
  end

  def can_deduct_more(value, projid)
    return true if (Project.find_by(id: projid).budget - value) >= 0 && @state

    false
  end

  def budgets_setter(projid, value)
    return false unless @state

    proj = Project.find_by(id: projid)
    proj.budget = value
    proj.save
    @state
  end
end
