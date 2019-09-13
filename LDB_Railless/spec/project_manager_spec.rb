# frozen_string_literal: true

require 'simplecov'
SimpleCov.start

require_relative '../lib/project_manager'
require_relative '../lib/project'
require_relative 'custom_matcher'

describe ProjectManager do
  let(:pm) { described_class.new }

  after do
    # Necessary to keep the projects.yml file intact
    hash = { 'someid' => { 'name' => 'projektas', 'manager' => 'john',
                           'members' => %w[john steve harry],
                           'status' => 'Suspended' } }
    File.open('projects.yml', 'w') do |fl|
      fl.write hash.to_yaml.gsub('---', '')
    end
  end

  it 'deleting an existing project' do
    expect(pm.delete_project(Project.new(num: 'someid'))).to be true
  end

  it 'file is clean of dashes and brackets after deletion' do
    pm.delete_project(Project.new(num: 'someid'))
    file = 'projects.yml'
    expect(file).not_to has_yml_nils
  end

  it 'creating an existing project id is a fail' do
    expect(pm.save_project(Project.new(num: 'someid'))).to be false
  end

  it 'can save new project' do
    expect(pm.save_project(Project.new(num: 'prid'))).to be true
  end

  it 'currently - no active projects' do
    # TODO: active project checking will be implemented later
    expect(pm.active_projects_present?).to be false
  end

  it 'project is actually written' do
    pm.save_project(Project.new(project_name: 'name', num: 'id'))
    hash = YAML.load_file('projects.yml')
    expect(hash['id']['name']).to eq 'name'
  end

  it 'project is actually removed' do
    pm.delete_project(Project.new(num: 'someid'))
    hash = YAML.load_file('projects.yml')
    expect(hash).to be false
  end

  it 'false on non-existing id' do
    expect(pm.load_project('noid')).to be false
  end

  it 'grabs name by id' do
    obj = pm.load_project('someid')
    expect(obj.data_getter('name')).to match('projektas')
  end

  it 'grabs manager by id' do
    obj = pm.load_project('someid')
    expect(obj.data_getter('manager')).to match('john')
  end

  it 'grabs members by id' do
    obj = pm.load_project('someid')
    expect(obj.members_getter).to match_array %w[john steve harry]
  end

  it 'grabs id by id' do
    obj = pm.load_project('someid')
    expect(obj.data_getter('id')).to satisfy do |id|
      id.eql?('someid')
    end
  end

  it 'grabs status by id' do
    obj = pm.load_project('someid')
    expect(obj.parm_project_status).to eq 'Suspended'
  end

  it 'lists ids and manes of projects' do
    expect(pm.list_projects).to match_array %w[someid:projektas]
  end

  context 'when projects.yml state is tested' do
    before do
      proj = Project.new(project_name: 'tst', manager: 'tst',
                         num: 'tst', members: %w[tst tst])
      proj.parm_project_status('Suspended')
      described_class.new.save_project(proj)
      described_class.new.delete_project(Project.new(num: 'someid'))
    end

    it 'checks saving' do
      current = 'projects.yml'
      state = 'state-projects.yml'
      expect(current).to is_yml_identical(state)
    end

    it 'checks loading' do
      hash = { 'tst' => { 'name' => 'tst', 'manager' => 'tst',
                          'members' => %w[tst tst],
                          'status' => 'Suspended' } }
      expect(YAML.load_file('projects.yml')).to is_data_identical(hash)
    end
  end

  context 'when adding member to the project' do
    it 'adds member to the project' do
      expect(pm.add_member_to_project('t@a.com', 'someid')).to be true
    end

    it 'returns false if member already exists' do
      pm.add_member_to_project('t@a.com', 'someid')
      expect(pm.add_member_to_project('t@a.com', 'someid')).to be false
    end

    it 'returns false if user is nil' do
      expect(pm.add_member_to_project(nil, 'someid')).to be false
    end

    it 'returns false if project id is nil' do
      expect(pm.add_member_to_project('someid', nil)).to be false
    end

    it 'returns false if add_member_to_project params are nil' do
      expect(pm.add_member_to_project(nil, nil)).to be false
    end

    it 'returns false if add_member_to_project\'s project id is invalid' do
      expect(pm.add_member_to_project('t@a', 'kukukuku')).to be false
    end
  end

  context 'when removing member from the project' do
    it 'removes member from the project' do
      pm.add_member_to_project('t@a.com', 'someid')
      expect(pm.remove_member_from_project('t@a.com', 'someid')).to be true
    end

    it 'returns false if member does not exist' do
      expect(pm.remove_member_from_project('t@a.com', 'someid')).to be false
    end

    it 'returns false if member is nil' do
      expect(pm.remove_member_from_project(nil, 'someid')).to be false
    end

    it 'returns false if project id is nil' do
      expect(pm.remove_member_from_project('someid', nil)).to be false
    end

    it 'returns false if remove_member_from_project params are nil' do
      expect(pm.remove_member_from_project(nil, nil)).to be false
    end

    it 'returns false if remove_member_from_project project id is invalid' do
      expect(pm.remove_member_from_project('t@a', 'kukukuku')).to be false
    end
  end

  it 'correctly adds and removes member' do
    before_file = YAML.load_file('projects.yml')
    pm.add_member_to_project('jhonyxx@aaa.com', 'someid')
    pm.remove_member_from_project('jhonyxx@aaa.com', 'someid')
    expect(YAML.load_file('projects.yml').eql?(before_file)).to be true
  end

  context 'when changing project status' do
    it 'sets project status correctly' do
      expect(pm.set_project_status('someid', 'Cancelled')).to be true
    end

    it 'returns false if project id is nil' do
      expect(pm.set_project_status(nil, 'Cancelled')).to be false
    end

    it 'returns false if set_project_status params are nil' do
      expect(pm.set_project_status(nil, nil)).to be false
    end

    it 'returns false if status is nil' do
      expect(pm.set_project_status('someid', nil)).to be false
    end

    it 'returns false if invalid status is set' do
      expect(pm.set_project_status('someid', 'bbububu')).to be false
    end

    it 'returns false if set_project_status project id is invalid' do
      expect(pm.set_project_status('kukukukuku', 'Cancelled')).to be false
    end

    it 'correctly saves status' do
      original = { 'someid' => { 'name' => 'projektas', 'manager' => 'john',
                                 'members' => %w[john steve harry],
                                 'status' => 'Cancelled' } }
      pm.set_project_status('someid', 'Cancelled')
      expect(YAML.load_file('projects.yml').eql?(original)).to be true
    end
  end
end
