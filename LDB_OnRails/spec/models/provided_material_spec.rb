# frozen_string_literal: true

require_relative 'custom_matcher'
require_relative '../rails_helper'

describe ProvidedMaterial do
  fixtures :all

  it 'actually deducts qty' do
    described_class.find_by(name: 'WoodWorks', material: 'Boards')
                   .deduct_qty(1000)
    expect(described_class.find_by(name: 'WoodWorks',
                                   material: 'Boards').unit).to eq '4000.0'
  end

  it 'actually adds qty' do
    described_class.find_by(name: 'WoodWorks', material: 'Boards')
                   .add_qty(1000)
    expect(described_class.find_by(name: 'WoodWorks',
                                   material: 'Boards').unit).to eq '6000.0'
  end
end
