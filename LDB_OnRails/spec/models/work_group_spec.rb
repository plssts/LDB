# frozen_string_literal: true

require_relative 'custom_matcher'
require_relative '../rails_helper'

describe WorkGroup do
  context 'when a member is being removed from the work_group' do
    it 'true when an existing member gets removed from the work_group' do
      group = described_class.create(projid: 453, budget: 300, name: 'Test')
      group.add_group_member('jhonpeterson@mail.com')
      expect(group.remove_group_member('jhonpeterson@mail.com')).to be true
    end

    it 'false if trying to remove non-existing member from the work_group' do
      group = described_class.create(projid: 453, budget: 300, name: 'Test')
      group.add_group_member('jhon@mail.com')
      expect(group.remove_group_member('jhonpeterson@mail.com')).to be false
    end
  end

  context 'when a new member is being added to the work_group' do
    it 'Returns true when a new member is added to the work_group' do
      group = described_class.create(projid: 453, budget: 300, name: 'Test')
      expect(group.add_group_member('jhonpeterson@mail.com')).to be true
    end

    it 'false if work group member is added again to the same work_group' do
      group = described_class.create(projid: 453, budget: 300, name: 'Test')
      group.add_group_member('jhonpeterson@mail.com')
      expect(group.add_group_member('jhonpeterson@mail.com')).to be false
    end
  end

  it 'retrieves tasks' do
    described_class.create(name: 'some')
    group = described_class.find_by(name: 'some')
    group.add_group_task(590)
    group.add_group_task(591)
    expect(described_class.find_by(name: 'some').tasks_getter).to eq [590, 591]
  end

  it 'deletes both by id and name' do
    described_class.create(name: 'Darbo gr').add_group_task(590)
    described_class.create(name: 'Antra gr').add_group_task(590)
    described_class.find_by(name: 'Darbo gr').remove_group_task(590)
    expect(described_class.find_by(name: 'Antra gr').remove_group_task(590))
      .to be true
  end

  it 'new task returns ture' do
    described_class.create(name: 'some')
    group = described_class.find_by(name: 'some')
    expect(group.add_group_task(590)).to be true
  end

  it 'updates self budget' do
    Project.create(id: 5555, budget: 1000)
    described_class.create(projid: 5555, name: 'some', budget: 690)
    group = described_class.find_by(name: 'some')
    group.project_budget_setter(600)
    expect(group.budget).to eq 600
  end

  it 'updates self budget 2' do
    gr = described_class.find_by(name: 'Antra grupe')
    Project.create(id: gr.projid, budget: 100)
    gr.project_budget_setter(6)
    gr.project_budget_setter(85)
    expect(gr.budget).to eq 85
  end

  it 'updates self budget 3' do
    gr = described_class.find_by(name: 'Trecia grupe')
    gr.project_budget_setter(11)
    expect(described_class.find_by(name: 'Trecia grupe').budget).to eq 11
  end

  it 'updates project budget' do
    Project.create(id: 5555, budget: 1000)
    Project.create(id: 5554, budget: 2000)
    described_class.create(projid: 5555, name: 'some', budget: 690)
    described_class.find_by(name: 'some').project_budget_setter(600)
    expect(Project.find_by(id: 5555).budget).to eq 1090
  end

  it 'retrieves members' do
    described_class.create(name: 'some')
    group = described_class.find_by(name: 'some')
    group.add_group_member('somemail')
    group.add_group_member('other')
    expect(group.members_getter).to eq %w[somemail other]
  end

  it 'removes member' do
    described_class.create(name: 'test')
    gr = described_class.find_by(name: 'test')
    gr.add_group_member('some@mail.com')
    gr.remove_group_member('some@mail.com')
    expect(gr.members_getter).to eq []
  end

  it 'doesnt remove if no member already' do
    gr = described_class.find_by(name: 'Darbo grupe')
    expect(gr.remove_group_member('nomembr')).to be false
  end

  it 'creates and removes task' do
    described_class.create(name: 'test')
    gr = described_class.find_by(name: 'test')
    gr.add_group_task(59)
    gr.remove_group_task(59)
    expect(gr.tasks_getter).to eq []
  end

  it 'manages multiple tasks by the name' do
    gr = described_class.find_by(name: 'Antra grupe')
    gr.add_group_task(100)
    gr.add_group_task(150)
    gr.remove_group_task(100)
    expect(gr.tasks_getter).to eq [58, 150]
  end

  it 'manages multiple tasks by the id' do
    described_class.find_by(name: 'Antra grupe').add_group_task(150)
    described_class.find_by(name: 'Antra grupe').add_group_task(160)
    described_class.find_by(name: 'Antra grupe').remove_group_task(160)
    expect(described_class.find_by(name: 'Antra grupe').tasks_getter)
      .to eq [58, 150]
  end

  it 'false if no task to delete' do
    gr = described_class.find_by(name: 'Antra grupe')
    expect(gr.remove_group_task('notask')).to be false
  end

  it 'same member can belong to multiple groups' do
    described_class.create(name: 'test')
    described_class.create(name: 'test2')
    described_class.find_by(name: 'test').add_group_member('pop')
    out = described_class.find_by(name: 'test2').add_group_member('pop')
    expect(out).to be true
  end
end
