# frozen_string_literal: true

require 'simplecov'
SimpleCov.start

require_relative '../lib/project'
require_relative '../lib/user'

describe Project do
  let(:pr) { described_class.new }
  let(:usr) { User.new }
  let(:pr2) do
    described_class.new(project_name: '1', manager: '2', num: '3',
                        members: '4')
  end

  context 'when project is validating its metadata, status, owner' do
    it 'has its owner set correctly' do
      proj = described_class.new
      proj.data_setter('manager', 'some name')
      expect(proj.data_getter('manager')).to eq 'some name'
    end

    it 'sets/returns valid status' do
      proj = described_class.new
      proj.parm_project_status('Proposed')
      expect(proj.parm_project_status).to eq 'Proposed'
    end
  end

  context 'when a member is being removed from the project' do
    it 'True when an existing member gets removed from the project' do
      proj = described_class.new
      e = 'jhonpeterson@mail.com'
      User.new(name: 'Jhon', last_name: 'Peterson', email: e)
      proj.add_member(e)
      expect(proj.remove_member(e)).to be true
    end

    it 'returns false when nonmember is being removed from the project' do
      proj = described_class.new
      e = 'jhonpeterson@mail.com'
      User.new(name: 'Jhon', last_name: 'Peterson', email: e)
      expect(proj.remove_member(e)).to be false
    end
  end

  context 'when a new member is being added to the project' do
    it 'returns true when a new member is added to the project' do
      proj = described_class.new
      e = 'jhonpeterson@mail.com'
      User.new(name: 'Jhon', last_name: 'Peterson', email: e)
      expect(proj.add_member(e)).to be true
    end

    it 'Return false when existing member is being added to the project' do
      proj = described_class.new
      e = 'jhonpeterson@mail.com'
      User.new(name: 'Jhon', last_name: 'Peterson', email: e)
      proj.add_member(e)
      expect(proj.add_member(e)).to be false
    end
  end

  it 'has its owner defined as the user after creation by default' do
    proj = described_class.new
    expect(proj.data_getter('manager')).to eq Etc.getlogin
  end

  it 'deleted status change' do
    pr.set_deleted_status
    expect(pr.parm_project_status).to eq 'Deleted'
  end

  it 'setting for deletion works' do
    expect(pr.set_deleted_status).to be true
  end

  it 'can add a new member' do
    expect(pr.add_member('somemail')).to be true
  end

  it 'non-existing member removal' do
    # id is blank
    expect(pr.remove_member(usr)).to be false
  end

  it 'can remove a member' do
    User.new(email: 'somemail')
    pr.add_member('somemail')
    expect(pr.remove_member('somemail')).to be true
  end

  it 'always return truthy status' do
    expect(pr.parm_project_status).to be_truthy
  end

  it 'cannot change to nondeterministic status' do
    expect(pr.parm_project_status('n')).to be false
  end

  it 'cancelled status is set correctly' do
    pr.parm_project_status('Cancelled')
    expect(pr.parm_project_status).to eq 'Cancelled'
  end

  it 'status is return in addition to being set' do
    expect(pr.parm_project_status('Cancelled')).to eq 'Cancelled'
  end

  it 'in progress is set correctly' do
    expect(pr.parm_project_status('In progress')).to eq 'In progress'
  end

  it 'cannot set deleted twice' do
    pr.set_deleted_status
    expect(pr.set_deleted_status).to be false
  end

  it 'manager is always a truthy object' do
    expect(pr.data_getter('manager')).to be_truthy
  end

  it 'member lists are not mixed up' do
    User.new(email: 'othermail')
    pr.add_member('othermail')
    pr.add_member('somemail')
    pr.remove_member('othermail')
    expect(pr.members_getter).to eq ['somemail']
  end

  it 'cannot remove non-existing member' do
    expect(pr.remove_member('somemail')).to be false
  end

  it 'initial status is proposed' do
    expect(pr.parm_project_status).to eq 'Proposed'
  end

  it 'default name is .. well, default project' do
    expect(pr.data_getter('name')).to eq 'Default_project_' + Date.today.to_s
  end

  it 'name is set correctly' do
    pr.data_setter('name', 'newname')
    expect(pr.data_getter('name')).to eq 'newname'
  end

  it 'postponed is set correctly' do
    expect(pr.parm_project_status('Postponed')).to eq 'Postponed'
  end

  it 'suspended is set correctly' do
    expect(pr.parm_project_status('Suspended')).to eq 'Suspended'
  end

  it 'proposed is set correctly' do
    expect(pr.parm_project_status('Proposed')).to eq 'Proposed'
  end

  it 'project is converted to hash correctly' do
    pr2.parm_project_status('Cancelled')
    expect(pr2.to_hash).to eq '3' => { 'name' => '1', 'manager' => '2',
                                       'members' => '4',
                                       'status' => 'Cancelled' }
  end

  it 'id is never nil' do
    expect(described_class.new.data_getter('id')).not_to be_nil
  end

  it 'id is always a number' do
    id = described_class.new.data_getter('id')
    expect(id).to be_kind_of(Numeric)
  end

  it 'the system can check whether its files have anything' do
    condition = true # Checks content
    File.open('budgets.yml', 'w') do |fl|
      fl.write nil.to_yaml
    end
    expect(condition).not_to be files_ready
  end

  it 'normally it passes fine' do
    condition = true # Checks content
    expect(condition).to files_ready
  end

  it 'the system has all needed resources available' do
    condition = false # Checks file presence only
    expect(condition).to files_ready
    hash = { 'someid' => { 'budget' => 35_000 } }
    File.open('budgets.yml', 'w') { |f| f << hash.to_yaml.gsub('---', '') }
    # Generates the file back for next tests
  end
end
