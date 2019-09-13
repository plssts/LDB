# frozen_string_literal: true

require_relative 'custom_matcher'
require_relative '../rails_helper'

describe NotesManager do
  fixtures :all

  let(:nm) do
    nm = described_class
    # Check passes - we only care that it happens
    allow(nm).to receive(:bad_words_included?).and_return(true)
    nm
  end

  it 'checks for bad words on creation' do
    nm.create(author: 'auth', name: 'name', text: 'bad')
    expect(nm).to have_received(:bad_words_included?)
  end

  it 'skips checking if name is already bad' do
    nm.create(author: 'auth', name: 'Back', text: 'text')
    expect(nm).not_to have_received(:bad_words_included?)
  end

  it 'does not call removing method if there are no expired notes' do
    described_class.find_by(name: 'Uzrasas3').destroy
    nm = described_class.new(author: 'ar@gmail.com', name: 'b')
    allow(nm).to receive(:remv_outdated)
    nm.list_notes
    expect(nm).not_to have_received(:remv_outdated)
  end

  # opposite case here
  it 'does call removing method if there are expired notes' do
    # described_class.find_by(name: 'Uzrasas3').destroy
    nm = described_class.new(author: 'ar@gmail.com', name: 'b')
    allow(nm).to receive(:remv_outdated)
    nm.list_notes
    expect(nm).to have_received(:remv_outdated)
  end

  it 'removes based on author as well' do
    nm = described_class.new(author: 'tg.gmail.com', text: 's')
    nm.remv_outdated(['Uzrasas1'])
    expect(described_class.find_by(name: 'Uzrasas1', author: 'ar@gmail.com'))
      .not_to be nil
  end

  it 'lists correct notes' do
    nm = described_class.new(name: 's', text: 's', author: 'ar@gmail.com')
    expect(nm.list_notes).to eq %w[Uzrasas1]
  end

  it 'similarly, false on non-existing text' do
    nm = described_class.new(text: 's')
    nm.delete_note('Uzrasas1', 'ar@gmail.com')
    expect(nm.note_getter('Uzrasas1', 'ar@gmail.com')).to be false
  end

  it 'retrieves note text' do
    nm = described_class.new(text: 's')
    expect(nm.note_getter('Uzrasas1', 'ar@gmail.com')).to eq 'some text'
  end

  it 'fails text retrieval on false' do
    nm = described_class.new # text is nil
    expect(nm.note_getter('Uzrasas1', 'ar@gmail.com')).to be false
  end

  it 'false if text is nil' do
    nm = described_class.new # text is nil
    expect(nm.remv_outdated(['Uzrasas3'])).to be false
  end

  it '[] if text is nil during population' do
    nm = described_class.new # text is nil
    expect(nm.populate).to eq []
  end

  it 'populates under right conditions' do
    nm = described_class.new(text: 's', author: 'ar@gmail.com')
    expect(nm.populate).to eq %w[Uzrasas1 Uzrasas3]
  end

  it 'does not populate if text is nil' do
    nm = described_class.new(author: 'ar@gmail.com')
    expect(nm.populate).to eq []
  end

  it 'does not delete if text is nil' do
    nm = described_class.new # text is nil
    expect(nm.delete_note('Uzrasas1', 'ar@gmail.com')).to be false
  end

  it 'deletes the right note (covers name only)' do
    nm = described_class.new(text: 's')
    nm.delete_note('Uzrasas1', 'tg.gmail.com')
    expect(described_class.find_by(name: 'Uzrasas1',
                                   author: 'ar@gmail.com').expire)
      .to be nil
  end

  it 'deletes the right note (covers author only)' do
    nm = described_class.new(text: 's')
    nm.delete_note('Uzrasas1', 'tg.gmail.com')
    expect(described_class.find_by(name: 'Uzrasas2',
                                   author: 'tg.gmail.com').expire)
      .to eq '2020-01-01'
  end

  it 'returns true after deleting' do
    nm = described_class.new(text: 's')
    expect(nm.delete_note('Uzrasas1', 'tg.gmail.com')).to be true
  end

  it 'does not work with name nil' do
    nm = described_class.new(author: 'ar@gmail.com') # name is nil
    nm.check_outdated
    expect(described_class.find_by(name: 'Uzrasas3', author: 'ar@gmail.com'))
      .not_to be nil
  end

  it 'deletes based on author too' do
    nm = described_class.new(name: 's', text: 's', author: 'ar@gmail.com')
    nm.check_outdated
    expect(described_class.find_by(name: 'Uzrasas1', author: 'tg.gmail.com'))
      .not_to be nil
  end

  it 'deletes current day notes' do
    described_class.create(text: 's', author: 'm',
                           expire: Date.current, name: 'tst')
    described_class.new(author: 'm', text: 's',
                        name: 's').check_outdated
    expect(described_class.find_by(name: 'tst', author: 'm')).to be nil
  end

  it 'does not delete valid notes 1' do
    nm = described_class.new(name: 's', text: 's', author: 'ar@gmail.com')
    nm.check_outdated
    expect(nm.list_notes).to eq %w[Uzrasas1]
  end

  it 'does not delete when name is nil' do
    nm = described_class.new(text: 's', author: 'ar@gmail.com')
    nm.check_outdated
    expect(nm.list_notes).to eq %w[Uzrasas1 Uzrasas3]
  end

  it 'does not delete valid notes 2' do
    nm = described_class.new(name: 's', text: 's', author: 'tg.gmail.com')
    nm.check_outdated
    expect(nm.list_notes).to eq %w[Uzrasas2]
  end

  it 'detects bad words 1' do
    nm = described_class
    result = nm.bad_words_included?('bad')
    expect(result).to be true
  end

  it 'detects bad words 2' do
    nm = described_class
    result = nm.bad_words_included?('word')
    expect(result).to be true
  end

  it 'detects bad words 3' do
    nm = described_class
    result = nm.bad_words_included?('reallyawful')
    expect(result).to be true
  end

  it 'good words are good words' do
    nm = described_class
    result = nm.bad_words_included?('ok try this')
    expect(result).to be false
  end
end
