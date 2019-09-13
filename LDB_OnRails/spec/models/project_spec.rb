# frozen_string_literal: true

require_relative 'custom_matcher'
require_relative '../rails_helper'

describe Project do
  fixtures :all

  let(:pr_alive) do
    pr_alive = described_class.find_by(name: 'Projektas2')
    allow(pr_alive).to receive(:exec_deleted_status).and_return(true)
    pr_alive
  end

  context 'when described_class is validating its metadata, status, owner' do
    it 'first time marking as deleted' do
      pr_alive.set_deleted_status
      expect(pr_alive).not_to have_received(:exec_deleted_status)
    end
  end

  it 'has its owner defined as the user after creation by default' do
    described_class.create(name: 'test', manager: 'guy')
    proj = described_class.find_by name: 'test'
    expect(proj.manager).to eq 'guy'
  end

  it 'deleted status change' do
    described_class.create(name: 'test', manager: 'guy', status: 'Proposed')
    described_class.find_by(name: 'test').set_deleted_status
    expect(described_class.find_by(name: 'test').status).to eq 'Deleted'
  end

  it 'setting for deletion works' do
    described_class.create(name: 'test')
    pr = described_class.find_by(name: 'test')
    expect(pr.set_deleted_status).to be true
  end

  it 'can add a new member' do
    described_class.create(name: 'test')
    pr = described_class.find_by name: 'test'
    expect(pr.add_member('somemail')).to be true
  end

  it 'can remove a member' do
    described_class.create(name: 'test2')
    proj = described_class.find_by name: 'test2'
    proj.add_member('userm')
    expect((described_class.find_by name: 'test2').remove_member('userm'))
      .to be true
  end

  it 'cannot change to nondeterministic status' do
    described_class.create(name: 'test')
    pr = described_class.find_by name: 'test'
    expect(pr.project_status_setter('n')).to be false
  end

  it 'cancelled status is set correctly' do
    described_class.create(name: 'test')
    pr = described_class.find_by name: 'test'
    pr.project_status_setter('Cancelled')
    expect(described_class.find_by(name: 'test').status).to eq 'Cancelled'
  end

  it 'in progress is set correctly' do
    described_class.create(name: 'test')
    pr = described_class.find_by name: 'test'
    pr.project_status_setter('In progress')
    expect(described_class.find_by(name: 'test').status).to eq 'In progress'
  end

  it 'members actually get saved' do
    described_class.create(name: 'test')
    described_class.find_by(name: 'test').add_member('othermail')
    described_class.find_by(name: 'test').add_member('somemail')
    expect(described_class.find_by(name: 'test').members_getter)
      .to eq %w[othermail somemail]
  end

  it 'covers \'find_by(nil)\'' do
    described_class.create(name: 'test')
    described_class.create(name: 'wow')
    described_class.find_by(name: 'wow').add_member('othermail')
    expect(described_class.find_by(name: 'wow').members_getter)
      .to eq %w[othermail]
  end

  it 'cannot remove non-existing member' do
    described_class.create(name: 'test')
    described_class.find_by(name: 'test').add_member('somemail')
    expect(described_class.find_by(name: 'test').remove_member('nomail'))
      .to be false
  end

  it 'member is actually deleted' do
    described_class.create(id: 1010)
    described_class.find_by(id: 1010).add_member('somemail')
    described_class.find_by(id: 1010).remove_member('somemail')
    expect(ProjectMember.find_by(member: 'somemail', projid: 1010))
      .to be nil
  end

  it 'member is correctly determined under project' do
    described_class.create(id: 1010).add_member('somemail')
    described_class.create(id: 2020).add_member('somemail')
    described_class.find_by(id: 2020).remove_member('somemail')
    expect(ProjectMember.find_by(member: 'somemail', projid: 1010))
      .not_to be nil
  end

  it 'postponed is set correctly' do
    described_class.create(name: 'test')
    pr = described_class.find_by name: 'test'
    pr.project_status_setter('Postponed')
    expect(described_class.find_by(name: 'test').status).to eq 'Postponed'
  end

  it 'suspended is set correctly' do
    described_class.create(name: 'test')
    pr = described_class.find_by name: 'test'
    pr.project_status_setter('Suspended')
    expect(described_class.find_by(name: 'test').status).to eq 'Suspended'
  end

  it 'proposed is set correctly' do
    described_class.create(name: 'test')
    pr = described_class.find_by name: 'test'
    pr.project_status_setter('Proposed')
    expect(described_class.find_by(name: 'test').status).to eq 'Proposed'
  end

  it 'spares other projects - covers \'find_by(self)\'' do
    described_class.create(id: 158)
    described_class.create(id: 159)
    proj = described_class.find_by(id: 159)
    proj.exec_deleted_status
    expect(described_class.find_by(id: 158)).not_to be nil
  end

  it 'executing deletion actually removes project' do
    described_class.create(id: 158)
    proj = described_class.find_by(id: 158)
    proj.exec_deleted_status
    expect(described_class.find_by(id: 158)).to be nil
  end

  it 'actually sets status to deleted' do
    proj = described_class.find_by(name: 'Projektas2')
    proj.set_deleted_status
    expect(described_class.find_by(name: 'Projektas2').status).to eq 'Deleted'
  end

  it 'actually deletes after second call' do
    proj = described_class.find_by(name: 'Projektas1')
    proj.set_deleted_status
    expect(described_class.find_by(name: 'Projektas1')).to be nil
  end

  it 'returns false after doing so' do
    proj = described_class.find_by(name: 'Projektas1')
    expect(proj.set_deleted_status).to be false
  end
end
