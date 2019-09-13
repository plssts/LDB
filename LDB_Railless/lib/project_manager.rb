# frozen_string_literal: true

require 'date'
require 'etc'
require_relative 'project'
require 'yaml'

# Project manipulation class
class ProjectManager
  def initialize
    @projects = YAML.load_file('projects.yml')
  end

  def load_file
    @projects = YAML.load_file('projects.yml')
  end

  def delete_project(project)
    @projects.delete(project.data_getter('id'))
    File.open('projects.yml', 'w') do |fl|
      fl.write @projects.to_yaml.sub('---', '').sub('{}', '')
    end
    true
  end

  def save_project(project)
    return false unless [nil].include?(@projects[project.data_getter('id')])

    File.open('projects.yml', 'a') do |fl|
      fl.write project.to_hash.to_yaml.sub('---', '')
    end
    load_file
    true
  end

  def load_project(id)
    return false unless @projects.key?(id)

    proj = projo = @projects.fetch(id)
    obj = Project.new(project_name: proj.fetch('name'),
                      manager: proj.fetch('manager'), num: id,
                      members: projo.fetch('members'))
    obj.parm_project_status(projo.fetch('status'))

    obj
  end

  def add_member_to_project(member, project_id)
    return false if [nil].include?(member)
    return false if [false].include?(project = load_project(project_id))
    return true if project.add_member(member) &&
                   delete_project(Project.new(num: project_id)) &&
                   save_project(project)

    false
  end

  def remove_member_from_project(member, project_id)
    return false if [false].include?(prj = load_project(project_id))

    return true if prj.remove_member(member) &&
                   delete_project(Project.new(num: project_id)) &&
                   save_project(prj)

    false
  end

  def set_project_status(project_id, status)
    return false if [nil].include?(status)
    return false if [false].include?(project = load_project(project_id))
    return false unless project.parm_project_status(status)

    delete_project(Project.new(num: project_id))
    save_project(project)
  end

  # TODO: placeholder - will be implemented later
  def active_projects_present?
    false
  end

  def list_projects
    arr = []
    @projects.each_key do |key|
      arr.push(key + ':' + @projects.fetch(key).fetch('name'))
    end
    arr
  end
end
