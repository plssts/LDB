# frozen_string_literal: true

# require_relative 'work_group'
require './application_record'
require 'yaml'

# Saves and writes work group related data
class WorkGroupManager
  def initialize
    @state = true
  end

  def stater(var = @state)
    @state = var
  end

  def save_group(name)
    WorkGroup.create(name: name)
    @state
  end

  def delete_group(group)
    return false unless @state

    wg = WorkGroup.find_by(id: group)
    wg.destroy
    true
  end

  def list_groups
    return false unless @state

    arr = []
    WorkGroup.ids.each do |el|
      arr.push(el.to_s + ':' + (WorkGroup.find_by id: el).name)
    end

    arr
  end
end
