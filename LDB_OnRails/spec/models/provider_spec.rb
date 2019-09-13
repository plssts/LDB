# frozen_string_literal: true

require_relative 'custom_matcher'
require_relative '../rails_helper'

describe Provider do
  fixtures :all

  let(:prov) do
    prov = described_class.find_by(name: 'SteelPool')
    # The true fact whether there are any offers is irrelevant
    allow(prov).to receive(:offers?).and_return(true)
    prov
  end

  it 'always checks whether there are offers before fetching them' do
    prov.materials_by_provider
    expect(prov).to have_received(:offers?)
  end

  # opposite case here
  it 'does not fetch offers when one of them has 0 available units' do
    provmat = ProvidedMaterial.find_by(name: 'SteelPool', material: 'Supports')
    provmat.unit = 0
    provmat.save
    prov.materials_by_provider
    expect(prov).not_to have_received(:offers?)
  end

  it 'has qty right now' do
    expect(described_class.new(name: 'WoodWorks').qty?).to be true
  end

  it 'false if no qty is positive' do
    provmat = ProvidedMaterial.find_by(name: 'Choppers', material: 'Planks')
    provmat.unit = provmat.unit.to_f - 350
    provmat.save
    expect(described_class.new(name: 'Choppers').qty?).to be false
  end

  it 'covers \'find_by(nil)\'' do
    ProvidedMaterial.create(name: 'test', material: 'test', unit: 0)
    expect(described_class.new(name: 'Choppers').qty?).to be true
  end

  it 'has offers when it has offers' do
    expect(described_class.new(name: 'WoodWorks').offers?).to be true
  end

  it 'vice versa' do
    expect(described_class.new(name: 'noCompany').offers?).to be false
  end

  it 'false when no offers' do
    expect(described_class.new(name: 'noCompany').materials_by_provider)
      .to be false
  end

  it 'actual materials retrieved' do
    expect(described_class.new(name: 'WoodWorks').materials_by_provider)
      .to eq %w[Planks Boards]
  end

  it 'retrieves all names' do
    expect(described_class.new(name: 's').all_names)
      .to eq %w[Choppers SteelPool WoodWorks]
  end

  it 'false if no name specified' do
    expect(described_class.new.all_names).to be false
  end
end
