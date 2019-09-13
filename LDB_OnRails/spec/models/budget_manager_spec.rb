# frozen_string_literal: true

require_relative 'custom_matcher'
require_relative '../rails_helper'

describe BudgetManager do
  let :bm do
    described_class.new
  end

  it 'retrieves the state' do
    expect(bm.stater).to be true
  end

  it 'returns state after setting budget' do
    Project.create(name: 'test', budget: 3.5, id: 'testid')
    bm.stater(11)
    expect(bm.budgets_setter('testid', 87)).to eq 11
  end

  it 'false when budget is too small' do
    id = Project.find_by(name: 'Projektas2').id
    # specific budget covers mutation 'find_by(nil)'
    expect(bm.can_deduct_more(35_000.11, id)).to be false
  end

  it 'false when state is false' do
    Project.create(name: 'test', manager: 'guy', status: 'Proposed',
                   budget: 3.5, id: 'testid')
    bm.stater(false)
    expect(bm.can_deduct_more(3, 'testid')).to be false
  end

  it 'true when budget is bigger than deduction' do
    id = Project.find_by(name: 'Projektas2').id
    expect(bm.can_deduct_more(3, id)).to be true
  end

  it 'covers mutation \'>= -1\'' do
    id = Project.find_by(name: 'Projektas2').id
    expect(bm.can_deduct_more(5000.6, id)).to be false
  end

  it 'true when budget is equal to deduction' do
    id = Project.find_by(name: 'Projektas1').id
    expect(bm.can_deduct_more(35_000.11, id)).to be true
  end

  it 'budget is set correctly' do
    id = Project.find_by(name: 'Projektas2').id
    bm.budgets_setter(id, 87)
    expect(Project.find_by(id: id).budget).to eq 87
  end

  it 'false when state is not true' do
    id = Project.find_by(name: 'Projektas2').id
    bm.stater(false)
    expect(bm.budgets_setter(id, 87)).to be false
  end

  it 'budget is also not changed' do
    id = Project.find_by(name: 'Projektas2').id
    bm.stater(false)
    bm.budgets_setter(id, 87)
    expect(Project.find_by(name: 'Projektas2').budget).not_to eq 87
  end
end
