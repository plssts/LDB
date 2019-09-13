# frozen_string_literal: true

require_relative 'custom_matcher'
require_relative '../rails_helper'

describe Order do
  fixtures :all

  let(:bm) do
    bm = BudgetManager.new
    # Only care if we receive checking
    allow(bm).to receive(:can_deduct_more).and_return(true)
    bm
  end

  let(:order) do
    order = described_class.create(material: 'Planks', provider: 'WoodWorks',
                                   projid: 'any', cost: 540, qty: 5, vat: 1)
    # The validity of cost is not important right now
    allow(order).to receive(:valid_cost).and_return(true)
    order
  end

  it 'checks if the budget is large enough for order' do
    Project.create(id: 'any', budget: '0')
    order = described_class.create(material: 'Planks', provider: 'WoodWorks',
                                   projid: 'any', cost: 540, qty: 5)
    order.deduct_budget(order.cost, bm)
    expect(bm).to have_received(:can_deduct_more)
  end

  it 'checks whether the cost is indeed = ppu * qty' do
    Project.create(id: 'any', budget: '0')
    order.deduct_budget(order.cost, bm)
    expect(order).to have_received(:valid_cost)
  end

  it 'cost is indeed valid' do
    ordr = described_class.new(provider: 'SteelPool', material: 'Beams',
                               qty: 150, cost: 7200)
    expect(ordr.valid_cost).to be true
  end

  it 'cost is miscalculated' do
    ordr = described_class.new(provider: 'SteelPool', material: 'Beams',
                               qty: 150, cost: 101)
    expect(ordr.valid_cost).to be false
  end

  it 'cost is calculated (not by provider only)' do
    ordr = described_class.new(provider: 'SteelPool', material: 'Supports',
                               qty: 50, cost: 1500)
    expect(ordr.valid_cost).to be true
  end

  it 'cost is calculated (not by material only)' do
    ordr = described_class.new(provider: 'Choppers', material: 'Planks',
                               qty: 10, cost: 200)
    expect(ordr.valid_cost).to be true
  end

  it 'order cost is transferred back' do
    Project.create(id: 'test', budget: 400)
    Project.create(id: 300, budget: 80)
    ordr = described_class.create(projid: 300, cost: 21)
    ordr.restore_budget
    expect(Project.find_by(id: 300).budget).to eq 101
  end

  it 'restoring budget deletes order' do
    Project.create(id: 'test', budget: 400)
    described_class.create(projid: 'test', cost: 21).restore_budget
    expect(described_class.find_by(projid: 'test', cost: 21)).to be nil
  end

  it 'completing an offer deletes it' do
    Project.create(id: 'test', budget: 400)
    ordr = described_class.create(projid: 'test', cost: 21)
    ordr.order_received
    expect(described_class.find_by(projid: 'test', cost: 21)).to be nil
  end

  it 'deducts budget' do
    Project.create(id: 'test', budget: 150)
    described_class.new(projid: 'test', provider: 'WoodWorks',
                        material: 'Planks', qty: 10, cost: 100, vat: 5)
                   .deduct_budget(100, BudgetManager.new)
    expect(Project.find_by(id: 'test').budget).to eq 50
  end

  it 'does notdeduct budget when vat = nil' do
    Project.create(id: 'test', budget: 150)
    ordr = described_class.new(projid: 'test', provider: 'WoodWorks',
                               material: 'Planks', qty: 10, cost: 100)
                          .deduct_budget(100, BudgetManager.new)
    expect(ordr).to be false
  end

  it 'returns true after deducting' do
    Project.create(id: 'test', budget: 150)
    ordr = described_class.new(projid: 'test', provider: 'WoodWorks',
                               material: 'Planks', qty: 10, cost: 100, vat: 5)
                          .deduct_budget(100, BudgetManager.new)
    expect(ordr).to be true
  end
end
