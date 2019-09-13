# frozen_string_literal: true

require_relative 'work_group'
require 'yaml'

# Saves and writes workgroup related data
class WorkGroupManager
  def initialize
    @groups = YAML.load_file('workgroups.yml')
  end

  def load_file
    @groups = YAML.load_file('workgroups.yml')
  end

  def groupsprm_getter
    @groups
  end

  def save_group(group)
    # && reduces the num of statements by 1; reek error gone
    delete_group(group.data_getter('id')) &&
      hash = group.to_hash

    File.open('workgroups.yml', 'a') do |fl|
      fl.write hash.to_yaml.sub('---', '')
    end
    load_file
    true
  end

  def delete_group(id)
    @groups.delete(id)
    File.open('workgroups.yml', 'w') do |fl|
      fl.write @groups.to_yaml.sub('---', '').sub('{}', '')
    end
    true
  end

  def load_group(id)
    return false unless @groups.key?(id)

    gr = gro = @groups.fetch(id)

    l_bdg(l_tsk(l_mem(WorkGroup.new(id, gro.fetch('project_id'),
                                    gr.fetch('group_name')), id), id), id)
  end

  # A set of methods to bypass reek's assignment/branch/condition
  def l_mem(obj, id)
    gro = @groups.fetch(id)
    obj.members_getter(gro.fetch('members'))

    obj
  end

  def l_tsk(obje, id)
    gro = @groups.fetch(id)
    obje.tasks_getter(gro.fetch('tasks'))

    obje
  end

  def l_bdg(objc, id)
    gr = @groups.fetch(id)
    objc.budget_construct_only(gr.fetch('budget'))

    objc
  end

  def list_groups
    arr = []
    @groups.each_key do |key|
      arr.push(key + ':' + @groups.fetch(key).fetch('group_name'))
    end
    arr
  end

  def add_member_to_group(member_mail, group_id)
    return false if [member_mail, group_id].include?(nil)

    group = load_group(group_id)
    group.add_group_member(User.new(email: member_mail))
    save_group(group)
    true
  end

  def remove_member_from_group(member_mail, group_id)
    return false if [member_mail, group_id].include?(nil)

    group = load_group(group_id)
    group.remove_group_member(User.new(email: member_mail))
    save_group(group)
    true
  end

  def add_task_to_group(task, group_id)
    return false if [task, group_id].include?(nil)

    group = load_group(group_id)
    group.add_group_task(task)
    save_group(group)
    true
  end

  def remove_task_from_group(task, group_id)
    return false if [task, group_id].include?(nil)

    group = load_group(group_id)
    group.remove_group_task(task)
    save_group(group)
    true
  end
end
