# frozen_string_literal: true

require 'date'
require 'etc'
require_relative 'project'
require './application_record'
require 'yaml'

# rubocop comment?
class ProjectManager
  def initialize
    @state = true
  end

  def stater(val = @state)
    @state = val
  end

  def delete_project(project)
    proj = Project.find_by(id: project)
    proj.destroy
    @state
  end

  def save_project(name, manager)
    Project.create(name: name, manager: manager)
    @state
  end

  def load_project(id)
    proj = projo = projt = projf = Project.find_by(id: id)
    return false unless proj && @state

    # will return a collection of attributes here
    [projf.name, proj.manager, projt.status, projo.budget]
  end

  # TODO: placeholder - will be implemented later
  def active_projects_present?
    false
  end

  def list_projects
    return false unless @state

    arr = []
    Project.ids.each do |pj|
      arr.push(pj.to_s + ':' + (Project.find_by id: pj).name)
    end

    arr
  end

  def gen_projects_and_members_hash
    return false unless @state

    prj_mem = fill_with_projids
    ProjectMember.all.each do |proj|
      prj_mem[proj.projid] += 1
    end
    prj_mem
  end

  def fill_with_projids
    @state = {}
    ProjectMember.all.each do |mem|
      @state[mem.projid] = 0
    end
    @state
  end
end
