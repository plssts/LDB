# frozen_string_literal: true

require 'simplecov'
SimpleCov.start

require_relative '../lib/work_group'
require_relative '../lib/user'
require_relative '../lib/project'

describe WorkGroup do
  let :wg do
    described_class.new('453', 'someid', 'Test')
  end

  after do
    # Necessary to keep workgroups.yml file intact during testing
    hash = { '453' => { 'project_id' => 'someid', 'group_name' => 'Test',
                        'members' => ['jhon@mail.com'], 'tasks' => 'sleep',
                        'budget' => 0 } }
    File.open('workgroups.yml', 'w') do |fl|
      fl.write hash.to_yaml.gsub('---', '')
    end

    hash = { 'someid' => { 'budget' => 35_000 } }
    File.open('budgets.yml', 'w') do |fl|
      fl.write hash.to_yaml.gsub('---', '')
    end
  end

  context 'when a member is being removed from the work_group' do
    it 'true when an existing member gets removed from the work_group' do
      group = described_class.new('453', '3324', 'Test')
      e = 'jhonpeterson@mail.com'
      vart = User.new(name: 'Jhon', last_name: 'Peterson', email: e)
      group.add_group_member(vart)
      expect(group.remove_group_member(vart)).to be true
    end

    it 'false if trying to remove non-existing member from the work_group' do
      group = described_class.new('453', '3324', 'Test')
      e = 'jhonpeterson@mail.com'
      vart = User.new(name: 'Jhon', last_name: 'Peterson', email: e)
      expect(group.remove_group_member(vart)).to be false
    end

    it 'member is actually removed' do
      vart = User.new(email: 'jhno@mail.com')
      wg.add_group_member(vart)
      wg.remove_group_member(vart)
      expect(wg.members_getter).to eq []
    end
  end

  it 'name is set correctly' do
    group = described_class.new('453', '3324', 'Test')
    group.data_setter('group_name', 'newname')
    expect(group.data_getter('group_name')).to eq 'newname'
  end

  it 'is possible to add a new task' do
    expect(wg.add_group_task('mytask')).to be true
  end

  it 'the task is retrieved' do
    wg.add_group_task('mytask')
    expect(wg.tasks_getter).to eq %w[mytask]
  end

  it 'deleting existing index works' do
    expect(wg.remove_group_task(0)).to be true
  end

  it 'deleted tasks are actually removed' do
    wg.add_group_task('mytask')
    wg.remove_group_task('mytask')
    expect(wg.tasks_getter).to eq []
  end

  it 'non-nil as well' do
    group = described_class.new('453', '3324', 'Test')
    expect(group.data_getter('group_name')).not_to be nil
  end

  it 'is always non-nil' do
    group = described_class.new('453', '3324', 'Test')
    e = 'jhonpeterson@mail.com'
    usr = User.new(name: 'Jhon', last_name: 'Peterson', email: e)
    expect(group.add_group_member(usr)).not_to be nil
  end

  it 'does not return nil' do
    group = described_class.new('453', '3324', 'Test')
    e = 'jhonpeterson@mail.com'
    usr = User.new(name: 'Jhon', last_name: 'Peterson', email: e)
    expect(group.remove_group_member(usr)).not_to be nil
  end

  context 'when a new member is being added to the work_group' do
    it 'Returns true when a new member is added to the work_group' do
      group = described_class.new('453', '3324', 'Test')
      e = 'jhonpeterson@mail.com'
      vart = User.new(name: 'Jhon', last_name: 'Peterson', email: e)
      expect(group.add_group_member(vart)).to be true
    end

    it 'false if work group member is added again to the same work_group' do
      group = described_class.new('453', '3324', 'Test')
      e = 'jhonpeterson@mail.com'
      vart = User.new(name: 'Jhon', last_name: 'Peterson', email: e)
      group.add_group_member(vart)
      expect(group.add_group_member(vart)).to be false
    end

    it 'Returns false when invalid User object is passed' do
      group = described_class.new('453', '3324', 'Test')
      e = 'jhonpeterson@mail.com'
      usr = User.new(name: 'Jhon', last_name: 'Peterson', email: e)
      expect(group.add_group_member(usr)).not_to be nil
    end
  end

  it 'correctly gets the name' do
    group = described_class.new('453', '3324', 'Test')
    group.data_setter('group_name', 'name')
    expect(group.data_getter('group_name')).to eq 'name'
  end

  context 'when assembling the hash' do
    before do
      wg.add_group_member(User.new(email: 'some@mail.com'))
      wg.add_group_task('mytask')
    end

    it 'assembles the hash correctly' do
      expect(wg.to_hash).to eq '453' => { 'project_id' => 'someid',
                                          'group_name' => 'Test',
                                          'members' => ['some@mail.com'],
                                          'tasks' => ['mytask'],
                                          'budget' => 0 }
    end
  end

  it 'correctly sets the budget' do
    wg.data_setter('budget', 300)
    expect(wg.data_getter('budget')).to equal 300
  end

  context 'when project budget is updated according to workgroup budget' do
    let(:wgo) do
      described_class.new('10', 'someid', 'name')
    end

    it 'project budget is updated according to workgroup budget' do
      budgets = YAML.load_file('budgets.yml')
      expect do
        wgo.data_setter('budget', 150)
        budgets = YAML.load_file('budgets.yml')
      end.to(change { budgets })
    end
  end

  it 'correctly changes the budget back' do
    wg = described_class.new('10', 'someid', 'name')
    wg.data_setter('budget', 150)
    wg.data_setter('budget', 0)
    expect(BudgetManager.new
           .budgets_getter('someid')).to be_within(0).of(35_000)
  end

  it 'does not lose money inbetween decreasing' do
    wg = described_class.new('10', 'someid', 'name')
    wg.data_setter('budget', 50)
    wg.data_setter('budget', 10)
    expect(BudgetManager.new.budgets_getter('someid')).to be == 34_990
  end

  it 'does not lose money inbetween increasing' do
    wg = described_class.new('10', 'someid', 'name')
    wg.data_setter('budget', 10)
    wg.data_setter('budget', 50)
    expect(BudgetManager.new.budgets_getter('someid')).to be == 34_950
  end

  it 'can handle budget correctly with multiple groups' do
    wg = described_class.new('10', 'someid', 'name')
    wg.data_setter('budget', 10)
    wg2 = described_class.new('11', 'someid', 'name')
    wg2.data_setter('budget', 10)
    expect(BudgetManager.new.budgets_getter('someid')).to be == 34_980
  end

  it 'passes if member with particular values are returned' do
    wg = described_class.new('10', 'someid', 'name')
    wg.members_getter(%w[1 2])
    expect(wg.members_getter(%w[1 2])).to eq %w[1 2]
  end

  it 'passes if prevoiusly added members are returned' do
    wg = described_class.new('10', 'someid', 'name')
    wg.members_getter(%w[1 2])
    expect(wg.members_getter).to eq %w[1 2]
  end

  it 'passes if tasks are setted and correctly returned' do
    wg = described_class.new('10', 'someid', 'name')
    wg.tasks_getter(%w[1 2])
    expect(wg.tasks_getter(%w[1 2])).to eq %w[1 2]
  end

  it 'passes if tasks with previously setted values are returned' do
    wg = described_class.new('10', 'someid', 'name')
    wg.tasks_getter(%w[1 2])
    expect(wg.tasks_getter).to eq %w[1 2]
  end

  it 'passes if groups budget is setted' do
    wg = described_class.new('10', 'someid', 'name')
    expect(wg.budget_construct_only(21)).to eq 21
  end

  it 'passes if budget was previously correctly setted' do
    wg = described_class.new('10', 'someid', 'name')
    wg.budget_construct_only(21)
    expect(wg.data_getter('budget')).to eq 21
  end
end
