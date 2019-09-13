# frozen_string_literal: true

require_relative 'custom_matcher'
require_relative '../rails_helper'

describe ProjectManager do
  let(:pm) { described_class.new }

  it 'deleting an existing project' do
    Project.create(name: 'test', manager: 'guy', status: 'Proposed', budget: 0)
    id = (Project.find_by name: 'test').id
    expect(pm.delete_project(id)).to be true
  end

  it 'currently - no active projects' do
    # TODO: active project checking will be implemented later
    expect(pm.active_projects_present?).to be false
  end

  it 'project is actually written' do
    pm.save_project('test', 'guy')
    id = (Project.find_by name: 'test').id
    expect(pm.load_project(id)).to eq ['test', 'guy', nil, nil]
  end

  it 'project is actually removed' do
    pm.save_project('test', 'guy')
    id = (Project.find_by name: 'test').id
    pm.delete_project(id)
    expect(pm.load_project(id)).to be false
  end

  it 'grabs name by id' do
    pm.save_project('test', 'guy')
    id = (Project.find_by name: 'test').id
    obj = pm.load_project(id)
    expect(obj[0]).to match('test')
  end

  it 'grabs manager by id' do
    pm.save_project('test', 'guy')
    id = (Project.find_by name: 'test').id
    obj = pm.load_project(id)
    expect(obj[1]).to match('guy')
  end

  it 'grabs status by id' do
    pm.save_project('test', 'guy')
    id = (Project.find_by name: 'test').id
    obj = pm.load_project(id)
    expect(obj[2]).to eq nil
  end

  it 'lists ids and manes of projects' do
    id = (Project.find_by name: 'Projektas2').id
    id2 = (Project.find_by name: 'Projektas1').id
    expect(pm.list_projects)
      .to match_array ['2018:nilly', '201050:act8', '101050:act',
                       "#{id}:Projektas2", "#{id2}:Projektas1"]
  end

  it 'project save returns state' do
    pm.stater(11)
    expect(pm.save_project('test', 'guy')).to eq 11
  end

  it 'counts project members' do
    ProjectMember.create(projid: 1001, member: 'wow@com')
    ProjectMember.create(projid: 1001, member: 'pop@com')
    hash = pm.gen_projects_and_members_hash
    expect(hash).to eq 0 => 3, 101_050 => 2, 201_050 => 1, 1001 => 2
  end

  it 'state false stops generating' do
    pm.stater(false)
    expect(pm.gen_projects_and_members_hash).to be false
  end

  it 'state false stops listing' do
    pm.stater(false)
    expect(pm.list_projects).to be false
  end

  it 'state false stops loading' do
    Project.create(id: 1001)
    pm.stater(false)
    expect(pm.load_project(1001)).to be false
  end

  it 'loads project' do
    Project.create(id: 1001, manager: 'test', status: 'Proposed', budget: 14,
                   name: 'tes')
    expect(pm.load_project(1001)).to eq ['tes', 'test', 'Proposed', 14]
  end

  it 'manipulates the state' do
    pm.stater(980)
    expect(pm.stater).to eq 980
  end
end
