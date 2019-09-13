# frozen_string_literal: true

require_relative 'custom_matcher'
require_relative '../rails_helper'

describe Search do
  fixtures :all

  let(:src) { described_class.new }

  let(:srstub) do
    srstub = described_class.new
    allow(srstub).to receive(:gather_data).and_return('dont care about value')
    srstub
  end

  it 'does not call data gathering with nil criteria' do
    srstub.search_by_criteria(['Anything'], nil)
    expect(srstub).not_to have_received(:gather_data)
  end

  it 'calls search if criteria is not nil' do
    srstub.search_by_criteria(['User'], 'anyval')
    expect(srstub).to have_received(:gather_data)
  end

  it 'no value returns empty string array' do
    expect(src.search_by_criteria(['Project'], 'noval')).to start_with([''])
  end

  it 'something is detected - message is returned' do
    expect(src.search_by_criteria(['User'],
                                  'Greblys')).to eq [['User has: ',
                                                      'Greblys']]
  end

  it 'handles multiple criteria' do
    expect(described_class.new.search_by_criteria(%w[WorkGroup
                                                     User], 'Darbo grupe'))
      .to start_with [%w[WorkGroup\ has:\  Darbo\ grupe]]
  end

  it 'result is delivered as an array of messages plus actual strings' do
    expect(described_class.new.search_by_criteria(%w[WorkGroup
                                                     Project
                                                     User], 'Antanas'))
      .to all be_an(Array).or be_an(String)
  end

  it 'search failure adds an ampty string anyway' do
    expect(described_class.new.search_by_criteria(%w[User], 'noval'))
      .to end_with ['']
  end

  it 'search failure if state is false' do
    src = described_class.new
    src.stater(false)
    expect(src.gather_data('WorkGroup', 'Darbo grupe')).to eq ''
  end

  it 'search failure if criteria is nil' do
    expect(described_class.new.search_by_criteria(%w[User], nil)).to eq []
  end

  it 'manipulates state' do
    src = described_class.new
    src.stater(20)
    expect(src.stater).to eq 20
  end
end
