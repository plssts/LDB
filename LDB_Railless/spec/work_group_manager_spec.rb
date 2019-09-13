# frozen_string_literal: true

require 'simplecov'
SimpleCov.start

require_relative '../lib/work_group_manager'
require_relative '../lib/work_group'
require_relative 'custom_matcher'
require 'date'
srand

describe WorkGroupManager do
  let(:wgm) do
    described_class.new
  end

  let(:newmemberhsh) do
    { '453' => { 'project_id' => 'someid',
                 'group_name' => 'Test',
                 'members' => %w[jhon@mail.com dude],
                 'tasks' => %w[sleep], 'budget' => 0 } }
  end

  let(:rmmemberhsh) do
    { '453' => { 'project_id' => 'someid',
                 'group_name' => 'Test',
                 'members' => %w[jhon@mail.com],
                 'tasks' => %w[sleep], 'budget' => 0 } }
  end

  let(:newtskhsh) do
    { '453' => { 'project_id' => 'someid',
                 'group_name' => 'Test',
                 'members' => ['jhon@mail.com'],
                 'tasks' => %w[sleep work], 'budget' => 0 } }
  end

  let(:rmtskhsh) do
    { '453' => { 'project_id' => 'someid',
                 'group_name' => 'Test',
                 'members' => ['jhon@mail.com'],
                 'tasks' => [], 'budget' => 0 } }
  end

  after do
    # Necessary to keep the workgroups.yml file intact
    hash = { '453' => { 'project_id' => 'someid', 'group_name' => 'Test',
                        'members' => ['jhon@mail.com'], 'tasks' => ['sleep'],
                        'budget' => 0 } }
    File.open('workgroups.yml', 'w') do |fl|
      fl.write hash.to_yaml.gsub('---', '')
    end

    hash = { 'someid' => { 'budget' => 35_000 } }
    File.open('budgets.yml', 'w') do |fl|
      fl.write hash.to_yaml.gsub('---', '')
    end
  end

  it 'saves a new group' do
    expect(wgm.save_group(WorkGroup.new('100', 'someid', 'name'))).to be_truthy
  end

  it 'new group is correctly saved to a file' do
    wg = WorkGroup.new('100', 'someid', 'name')
    wgm.save_group(wg)
    expect(wg.to_hash).to be_correctly_saved('workgroups.yml')
  end

  it 'rewriting existing group doesn\'t create duplicates' do
    wgm.save_group(WorkGroup.new('453', 'someid', 'name'))
    file = 'workgroups.yml'
    key = '453'
    expect(key).to is_key_unique(file)
  end

  it 'deleting an existing group' do
    expect(wgm.delete_group('453')).to be true
  end

  it 'last group is removed and file is empty' do
    wgm.delete_group('453')
    hash = YAML.load_file('workgroups.yml')
    expect(hash).to be false # empty file
  end

  it 'deleted group is actually removed' do
    wgm.save_group(WorkGroup.new('100', 'someid', 'name'))
    described_class.new.delete_group('453')
    hash = YAML.load_file('workgroups.yml')
    expect(hash).not_to have_key('453')
  end

  context 'when some workgroups together on same project' do
    before do
      grp = WorkGroup.new('newid', 'someid', 'name')
      grp.data_setter('budget', rand(100))
      described_class.new.save_group(grp)
    end

    it 'bunches up some workgroups together on same project' do
      expect(BudgetManager.new.budgets_getter('someid'))
        .to be_between(10_000, 40_000)
    end
  end

  context 'when workgroups.yml state is tested' do
    before do
      gr = WorkGroup.new('tst', 'someid', 'tst')
      gr.data_setter('budget', 101)
      gr.add_group_member(User.new(email: 'memb@r.tst'))
      gr.add_group_task('tst')
      described_class.new.save_group(gr)
      described_class.new.delete_group('453')
    end

    it 'checks saving' do
      current = 'workgroups.yml'
      state = 'state-workgroups.yml'
      expect(current).to is_yml_identical(state)
    end

    it 'checks loading' do
      hash = { 'tst' => { 'project_id' => 'someid', 'group_name' => 'tst',
                          'members' => ['memb@r.tst'], 'tasks' => ['tst'],
                          'budget' => 101 } }
      expect(YAML.load_file('workgroups.yml')).to is_data_identical(hash)
    end
  end

  context 'when covering group loading from hash' do
    let :checkval do
      gr = described_class.new.load_group('453')

      checkval = gr.data_getter('id').eql?('453') &&
                 gr.data_getter('project_id').eql?('someid') &&
                 gr.data_getter('group_name').eql?('Test') &&
                 gr.members_getter.eql?(['jhon@mail.com']) &&
                 gr.tasks_getter.eql?(['sleep']) &&
                 gr.data_getter('budget').eql?(0)
      checkval
    end

    let :samplegroup do
      described_class.new.l_bdg(WorkGroup.new('a', 'a', 'a'), '453')
                     .data_getter('budget')
    end

    it 'returns true if group loading was covered' do
      expect(checkval).to be true
    end

    it 'returns false if such group does not exist' do
      expect(described_class.new.load_group('nodi')).to be false
    end

    it 'passes if list of work groups match with given values' do
      expect(described_class.new.list_groups).to eq ['453:Test']
    end

    it 'passes if work groups members budget equal to particular value' do
      expect(described_class.new.l_mem(WorkGroup.new('a', 'a', 'a'),
                                       '453').data_getter('budget'))
        .to eq 0
    end

    it 'passes if work group has a task to sleep' do
      expect(described_class.new.l_tsk(WorkGroup.new('a', 'a', 'a'),
                                       '453').tasks_getter)
        .to eq ['sleep']
    end

    it 'passes if loaded group budget is successfully changed' do
      saved = described_class.new.load_group('453')
      saved.data_setter('budget', 50)
      described_class.new.save_group(saved)
      expect(samplegroup).to eq 50
    end

    it 'passes if to this work group belongs this member' do
      expect(described_class.new.l_mem(WorkGroup.new('a', 'a', 'a'),
                                       '453').members_getter)
        .to eq ['jhon@mail.com']
    end

    it 'passes if work groups budget equal to particular value' do
      expect(described_class.new.l_bdg(WorkGroup.new('a', 'a', 'a'),
                                       '453').data_getter('budget'))
        .to eq 0
    end
  end

  it 'adds a member to a group with nil params' do
    expect(wgm.add_member_to_group(nil, nil)).to be false
  end

  it 'normally returns true if member is added' do
    expect(wgm.add_member_to_group('dude', '453')).to be true
  end

  it 'adds a member to a group with one of params nil' do
    expect(wgm.add_member_to_group(nil, 200) ||
           wgm.add_member_to_group('t@a.com', nil)).to be false
  end

  it 'new group member is actually saved' do
    wgm.add_member_to_group('dude', '453')
    hsh1 = YAML.load_file('workgroups.yml')
    expect(hsh1).to eq newmemberhsh
  end

  it 'removes a member from a group with nil params' do
    expect(wgm.remove_member_from_group(nil, nil)).to be false
  end

  it 'normally returns true if member is removed' do
    expect(wgm.remove_member_from_group('jhon@mail.com', '453')).to be true
  end

  it 'removes a member from a group with one of params nil' do
    expect(wgm.remove_member_from_group(nil, 200) ||
           wgm.remove_member_from_group('t@a.com', nil)).to be false
  end

  it 'member is actually removed' do
    wgm.add_member_to_group('dude', '453')
    wgm.remove_member_from_group('dude', '453')
    hsh1 = YAML.load_file('workgroups.yml')
    expect(hsh1).to eq rmmemberhsh
  end

  it 'adds a task to a group with nil params' do
    expect(wgm.add_task_to_group(nil, nil)).to be false
  end

  it 'normally returns true if task is added' do
    expect(wgm.add_task_to_group('work', '453')).to be true
  end

  it 'adds a task to a group with one of params nil' do
    expect(wgm.add_task_to_group(nil, 200) ||
           wgm.add_task_to_group('work', nil)).to be false
  end

  it 'new task is actually saved' do
    wgm.add_task_to_group('work', '453')
    hsh1 = YAML.load_file('workgroups.yml')
    expect(hsh1).to eq newtskhsh
  end

  it 'removes a task from a group with nil params' do
    expect(wgm.remove_task_from_group(nil, nil)).to be false
  end

  it 'normally returns true if task is removed' do
    expect(wgm.remove_task_from_group('sleep', '453')).to be true
  end

  it 'removes a task from a group with one of params nil' do
    expect(wgm.remove_task_from_group(nil, 200) ||
           wgm.remove_task_from_group('work', nil)).to be false
  end

  it 'task is actually removed' do
    wgm.remove_task_from_group('sleep', '453')
    hsh1 = YAML.load_file('workgroups.yml')
    expect(hsh1).to eq rmtskhsh
  end

  it 'returns current yml state' do
    expect(wgm.groupsprm_getter).to eq YAML.load_file('workgroups.yml')
  end
end
