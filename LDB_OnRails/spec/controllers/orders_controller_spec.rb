# frozen_string_literal: true

require_relative '../rails_helper'
require 'date'

describe OrdersController do
  include Devise::Test::ControllerHelpers
  fixtures :all

  let(:ordr) do
    { ppu: '30', order: { qty: '2', provider: 'SteelPool', vat: 2,
                          recvaccount: 'b', contactname: 'c', unit: 'd',
                          material: 'Supports', projid: 60 } }
  end

  it 'covers mutation -if key' do
    expect { post :create, params: {} }
      .not_to raise_error(ActionController::ParameterMissing)
  end

  it 'actually deletes order' do
    oid = Order.find_by(provider: 'SteelPool', material: 'Supports').id
    post :destroy, params: { id: oid }
    order = Order.find_by(provider: 'SteelPool', material: 'Supports')
    expect(order).to be nil
  end

  it 'order is deleted, qty is returned to provider' do
    oid = Order.find_by(provider: 'SteelPool', material: 'Supports').id
    post :destroy, params: { id: oid }
    pm = ProvidedMaterial.find_by(name: 'SteelPool', material: 'Supports')
    expect(pm.unit.to_f).to eq 1050.0
  end

  it 'completing order means no qty increase for provider' do
    oid = Order.find_by(provider: 'SteelPool', material: 'Supports').id
    post :destroy, params: { id: oid, comp: true }
    pm = ProvidedMaterial.find_by(name: 'SteelPool', material: 'Supports')
    expect(pm.unit.to_f).to eq 1000.0
  end

  it 'actually creates order and deducts offer qty' do
    post :create, params: ordr
    pm = ProvidedMaterial.find_by(name: 'SteelPool', material: 'Supports')
    expect(pm.unit.to_f).to eq 998.0
  end

  it 'actually creates order' do
    post :create, params: ordr
    od = Order.find_by(provider: 'SteelPool', material: 'Supports', vat: 2,
                       projid: 60, cost: 60, recvaccount: 'b',
                       contactname: 'c', unit: 'd', qty: 2)
    expect(od).not_to be nil
  end

  it 'date is also filled' do
    post :create, params: ordr
    od = Order.find_by(provider: 'SteelPool', material: 'Supports', vat: 2,
                       projid: 60, cost: 60, recvaccount: 'b',
                       contactname: 'c', unit: 'd', qty: 2)
    expect(od.date.to_s).to start_with(Time.current.to_s[0..11])
  end
end
