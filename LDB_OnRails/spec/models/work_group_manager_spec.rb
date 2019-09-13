# frozen_string_literal: true

require_relative 'custom_matcher'
require_relative '../rails_helper'
require 'date'
srand

describe WorkGroupManager do
  it 'saves a new group' do
    expect(described_class.new.save_group('name')).to be_truthy
  end

  it 'last group is removed and file is empty' do
    WorkGroup.create(name: 'newgr')
    wg = WorkGroup.find_by(name: 'newgr').id
    expect(described_class.new.delete_group(wg)).to be true
  end

  it 'manipulates the state' do
    wg = described_class.new
    wg.stater(50)
    expect(wg.stater).to eq 50
  end

  it 'stops deletion under wrong state' do
    wg = described_class.new
    WorkGroup.create(id: 1005)
    wg.stater(false)
    expect(wg.delete_group(1005)).to be false
  end

  it 'group deletion' do
    wg = described_class.new
    id = WorkGroup.find_by(name: 'Antra grupe').id
    wg.delete_group(id)
    expect(WorkGroup.find_by(name: 'Antra grupe')).to be nil
  end

  it 'covers \'find_by(nil\')' do
    wg = described_class.new
    WorkGroup.create(id: 888, name: 'dud')
    WorkGroup.create(id: 155, name: 'testine grupe')
    wg.delete_group(888)
    expect(WorkGroup.find_by(name: 'dud')).to be nil
  end

  it 'lists groups' do
    WorkGroup.delete_all # we dont know the ids in fixtures, so...
    WorkGroup.create(id: 1005, name: 'test')
    WorkGroup.create(id: 1801, name: 'sos')
    expect(described_class.new.list_groups).to eq ['1005:test', '1801:sos']
  end

  it 'stops listing groups with false state' do
    wgm = described_class.new
    wgm.stater(false)
    expect(wgm.list_groups).to be false
  end

  it 'saves group' do
    described_class.new.save_group('test')
    expect(WorkGroup.find_by(name: 'test')).not_to be nil
  end

  it 'returns state after saving group' do
    ret = described_class.new.save_group('test')
    expect(ret).to be true
  end
end
