# frozen_string_literal: true

require 'date'
require 'etc'
srand 0

# Defines a Project
class Project
  def initialize(
    project_name: 'Default_project_' + Date.today.to_s,
    manager: Etc.getlogin, num: Random.rand, members: []
  )
    @name_man_id = { name: project_name,
                     manager: manager, id: num }
    @members = members
    @project_status = 'Proposed'
  end

  def data_getter(key)
    @name_man_id.fetch(key.to_sym)
  end

  def data_setter(key, val)
    @name_man_id[key.to_sym] = val
  end

  def to_hash
    { data_getter('id') => { 'name' => data_getter('name'),
                             'manager' => data_getter('manager'),
                             'members' => members_getter,
                             'status' => parm_project_status } }
  end

  def parm_project_status(status = '')
    if !status.empty?
      return @project_status = status if ['Proposed', 'Suspended', 'Postponed',
                                          'Cancelled',
                                          'In progress'].include? status

      false
    else
      @project_status
    end
  end

  def add_member(mail)
    return false if @members.include?(mail)

    @members.push(mail)
    true
  end

  def remove_member(mail)
    return false unless @members.include?(mail)

    @members.delete(mail)
    true
  end

  def members_getter
    @members
  end

  def set_deleted_status
    if @project_status.equal?('Deleted')
      false
    else
      @project_status = 'Deleted'
      true
    end
  end
end
