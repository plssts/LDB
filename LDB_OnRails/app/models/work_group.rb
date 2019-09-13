# frozen_string_literal: true

require './application_record'
require_relative 'work_group_member'
require_relative 'work_group_task'

# Defines a workgroup
class WorkGroup < ApplicationRecord
  has_many :work_group_members
  has_many :work_group_tasks

  def members_getter
    arr = []
    list = WorkGroupMember.where(wgid: self)
    list.each do |mem|
      arr.push(mem.member)
    end
    arr
  end

  def project_budget_setter(amount)
    oldbudget = budget
    self.budget = amount
    save
    old = Project.find_by(id: projid).budget
    BudgetManager.new.budgets_setter(projid, old + (oldbudget - amount))
  end

  def add_group_member(mail)
    return false if WorkGroupMember.find_by(wgid: self, member: mail)

    WorkGroupMember.create(wgid: id, member: mail)
    true
  end

  def remove_group_member(mail)
    wgm = WorkGroupMember.find_by(wgid: self, member: mail)
    return false if [nil].include?(wgm)

    wgm.destroy
    true
  end

  def add_group_task(task)
    WorkGroupTask.create(wgid: id, task: task)
    true
  end

  def remove_group_task(task)
    wgt = WorkGroupTask.find_by(wgid: self, task: task)
    return false if [nil].include?(wgt)

    wgt.destroy
    true
  end

  def tasks_getter
    arr = []
    list = WorkGroupTask.where(wgid: self)
    list.each do |tsk|
      arr.push(tsk.task)
    end
    arr
  end
end
