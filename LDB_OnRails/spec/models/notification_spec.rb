# frozen_string_literal: true

require_relative 'custom_matcher'
require_relative '../rails_helper'

describe Notification do
  fixtures :all

  let(:notif) do
    described_class.new
  end

  it 'false if sendr is not specified initially' do
    expect(described_class.new.edit_message('tg@gmail.com',
                                            'ar@gmail.com', 'new'))
      .to be false
  end

  it 'msg is actually changed' do
    described_class.new(sendr: 's').edit_message('tg@gmail.com',
                                                 'ar@gmail.com', 'new')
    expect(described_class.find_by(sendr: 'tg@gmail.com').msg).to eq 'new'
  end

  it 'not by sender only' do
    described_class.new(sendr: 's').edit_message('tg@gmail.com',
                                                 'other', 'new')
    expect(described_class.find_by(sendr: 'tg@gmail.com', recvr: 'other').msg)
      .to eq 'new'
  end

  it 'not by receiver only' do
    described_class.new(sendr: 's').edit_message('ar@gmail.com',
                                                 'other', 'new')
    expect(described_class.find_by(sendr: 'ar@gmail.com', recvr: 'other').msg)
      .to eq 'new'
  end

  it 'returns self.msg during change' do
    out = described_class.new(sendr: 's', msg: 'test')
                         .edit_message('tg@gmail.com', 'ar@gmail.com', 'new')
    expect(out).to eq 'test'
  end

  it 'false if sendr not initialized' do
    expect(described_class.new.read_message('tg@gmail.com',
                                            'ar@gmail.com'))
      .to be false
  end

  it 'actually returns the message' do
    out = described_class.new(sendr: 's').read_message('tg@gmail.com',
                                                       'ar@gmail.com')
    expect(out).to eq 'Dont forget to do your task'
  end

  it 'actually returns the message not by sendr' do
    out = described_class.new(sendr: 's').read_message('tg@gmail.com',
                                                       'other')
    expect(out).to eq 'Some nonsense'
  end

  it 'actually returns the message not by recvr' do
    out = described_class.new(sendr: 's').read_message('other',
                                                       'ar@gmail.com')
    expect(out).to eq 'No it isnt'
  end

  it 'read message is deleted' do
    described_class.new(sendr: 's', recvr: 's').read_message('tg@gmail.com',
                                                             'ar@gmail.com')
    out = described_class.find_by(sendr: 'tg@gmail.com', recvr: 'ar@gmail.com')
    expect(out).to be nil
  end

  it 'gets senders by self.recvr' do
    out = described_class.new(recvr: 'tg@gmail.com').senders_getter
    expect(out).to eq %w[ar@gmail.com]
  end

  it 'false if recvr not initialized' do
    expect(described_class.new.truncate_read('tg@gmail.com',
                                             'ar@gmail.com'))
      .to be false
  end

  it 'checks if both arguments are taken into account' do
    described_class.new(recvr: 's').truncate_read('tg@gmail.com',
                                                  'ar@gmail.com')
    out1 = described_class.find_by(sendr: 'tg@gmail.com')
    out2 = described_class.find_by(sendr: 'ar@gmail.com')
    expect([nil].include?(out1) && [nil].include?(out2)).to be false
  end

  it 'notification actually deleted' do
    described_class.new(recvr: 's').truncate_read('tg@gmail.com',
                                                  'ar@gmail.com')
    out = described_class.find_by(sendr: 'tg@gmail.com', recvr: 'ar@gmail.com')
    expect(out).to be nil
  end

  it 'no notification returns false' do
    out = described_class.new(recvr: 's').truncate_read('nope',
                                                        'ar@gmail.com')
    expect(out).to be false
  end

  it 'deleting is both-parm based 1' do
    described_class.new(recvr: 's').truncate_read('tg@gmail.com',
                                                  'ar@gmail.com')
    out = described_class.find_by(sendr: 'tg@gmail.com', recvr: 'other')
    expect(out).not_to be nil
  end

  it 'deleting is both-parm based 2' do
    described_class.new(recvr: 's').truncate_read('ar@gmail.com',
                                                  'other')
    out = described_class.find_by(sendr: 'ar@gmail.com', recvr: 'tg@gmail.com')
    expect(out).not_to be nil
  end
end
