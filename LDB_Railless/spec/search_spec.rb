# frozen_string_literal: true

require 'simplecov'
SimpleCov.start

require_relative '../lib/search'

describe Search do
  let(:src) { described_class.new }

  it 'ready files included' do
    files = %w[users.yml projects.yml workgroups.yml budgets.yml notes.yml]
    arr2 = src.ymls_getter
    expect([files]).to contain_exactly(arr2)
  end

  it 'instance is always holding a true value' do
    expect(src.parm_instancevariable).to be true
  end

  it 'keys are always defined by default' do
    arg = %w[Users Projects WorkGroups Budgets Notes]
    expect(src.yml_key_check(arg)).to be true
  end

  it 'incorrect keys are caught' do
    arg = %w[Users Projects noval Budgets Notes]
    expect(src.yml_key_check(arg)).to be false
  end

  it 'returns value(s) according to the search criteria' do
    expect(src.search_by_criteria(['Projects'], 'noval')).to start_with([''])
  end

  it 'something is detected - message is returned' do
    expect(src.search_by_criteria(['Users'],
                                  'tomas')).to eq [['users t@a.com contain: ',
                                                    'tomas']]
  end

  it 'result is delivered as an array of messages plus actual strings' do
    expect(described_class.new.search_by_criteria(%w[WorkGroups
                                                     Budgets Projects
                                                     Users], 'jhon@mail.com'))
      .to all be_an(Array).or be_an(String)
  end

  it 'sets correctly on instvar' do
    expect(src.parm_instancevariable(false)).to be false
  end

  it 'passes if these are the subkeys' do
    expect(src.grab_subkeys('id' => { 1 => '', 2 => '' }))
      .to eq ['id', { 1 => '', 2 => '' }]
  end

  it 'search failure adds an ampty string anyway' do
    expect(described_class.new.search_by_criteria(%w[Users], 'noval'))
      .to end_with ['']
  end

  it 'detects false state and does nothing' do
    src.parm_instancevariable(false)
    expect(src.grab_subkeys('str' => { 'str' => 'str' })).to eq []
  end
end
