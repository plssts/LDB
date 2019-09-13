# frozen_string_literal: true

require_relative '../rails_helper'

describe MaterialsController do
  include Devise::Test::ControllerHelpers
  fixtures :all

  let(:newprov) do
    { material: { name: 'naujas' } }
  end

  it 'covers mutation -if key' do
    expect { post :addprov, params: {} }
      .not_to raise_error(ActionController::ParameterMissing)
  end

  it 'covers mutation -if key, on offers' do
    expect { post :addof, params: {} }
      .not_to raise_error(ActionController::ParameterMissing)
  end

  it 'actually deletes provider' do
    pid = Provider.find_by(name: 'SteelPool').id
    post :remprov, params: { id: pid }
    prov = Provider.find_by(name: 'SteelPool')
    expect(prov).to be nil
  end

  it 'actually deletes offer' do
    pid = ProvidedMaterial.find_by(name: 'SteelPool', material: 'Beams').id
    post :remof, params: { id: pid }
    prov = ProvidedMaterial.find_by(name: 'SteelPool', material: 'Beams')
    expect(prov).to be nil
  end

  it 'actually creates offer' do
    post :addof, params: { material: { name: 'naujas', material: 'Cars',
                                       unit: 20, ppu: 1500 } }
    prov = ProvidedMaterial.find_by(name: 'naujas', material: 'Cars',
                                    unit: 20, ppu: '1500')
    expect(prov).not_to be nil
  end

  it 'actually creates provider' do
    post :addprov, params: newprov
    prov = Provider.find_by(name: 'naujas')
    expect(prov).not_to be nil
  end
end
