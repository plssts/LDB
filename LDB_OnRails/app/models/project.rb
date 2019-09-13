# frozen_string_literal: true

require 'date'
require 'etc'
require './application_record'
require_relative 'project_member'
srand 0

# rubocop comment?
class Project < ApplicationRecord
  has_many :project_members

  def members_getter
    arr = []
    list = ProjectMember.where(projid: self)
    list.each do |mem|
      arr.push(mem.member)
    end
    arr
  end

  # Only setter. Getting status is simply Project.find_by().status
  def project_status_setter(status)
    if ['Proposed', 'Suspended', 'Postponed',
        'Cancelled', 'In progress'].include? status
      self.status = status
      save
    else
      false
    end
  end

  def add_member(mail)
    ProjectMember.create(projid: id, member: mail)
    true
  end

  def remove_member(mail)
    pm = ProjectMember.find_by(projid: self, member: mail)
    return false if [nil].include?(pm)

    pm.destroy
    true
  end

  def set_deleted_status
    if status.eql?('Deleted')
      exec_deleted_status
      false
    else
      self.status = 'Deleted'
      save
      true
    end
  end

  def exec_deleted_status
    ProjectManager.new.delete_project(self)
  end
end
