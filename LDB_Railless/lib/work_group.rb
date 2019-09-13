# frozen_string_literal: true

require_relative 'user'

# Defines a workgroup
class WorkGroup
  def initialize(id, project_id, group_name)
    @data = { id: id, project_id: project_id,
              group_name: group_name, budget: 0 }
    @members = []
    @tasks = []
  end

  def data_getter(key)
    @data.fetch(key.to_sym)
  end

  def data_setter(key, val)
    project_budget_setter(val) if key.equal?('budget')
    @data[key.to_sym] = val
  end

  # Is used only when a group is loaded from hash
  def budget_construct_only(val)
    @data[:budget] = val
  end

  def project_budget_setter(amount)
    projid = @data.fetch(:project_id)
    budget = @data.fetch(:budget)
    old = BudgetManager.new.budgets_getter(projid)
    BudgetManager.new.budgets_setter(projid, old + (budget - amount))
  end

  def to_hash
    {
      data_getter('id') => {
        'project_id' => data_getter('project_id'),
        'group_name' => data_getter('group_name'),
        'members' => members_getter,
        'tasks' => tasks_getter,
        'budget' => data_getter('budget')
      }
    }
  end

  def add_group_member(user)
    address = user.data_getter('email')
    return false if @members.include?(address)

    @members.push(address)
    true
  end

  def remove_group_member(user)
    address = user.data_getter('email')
    return false unless @members.include?(address)

    @members.delete(address)
    true
  end

  def add_group_task(task)
    @tasks.push(task)
    true
  end

  def remove_group_task(task)
    @tasks.delete(task)
    true
  end

  def members_getter(val = @members)
    @members = val
  end

  def tasks_getter(val = @tasks)
    @tasks = val
  end
end
