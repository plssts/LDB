# frozen_string_literal: true

require 'simplecov'
SimpleCov.start

require_relative '../lib/notes_manager'
require_relative 'custom_matcher'
require_relative '../lib/project'

describe NotesManager do
  let :nm do
    described_class.new(Date.today)
  end

  # Hashes related to mutation coverage
  let(:thash_o) do
    { 'n' => { 'author' => 'u', 'text' => 't', 'exp' => '1990-01-01' } }
  end

  let(:thash_t) do
    { 'm' => { 'author' => 'u', 'text' => 't', 'exp' => '2099-01-01' } }
  end

  let(:thash_f) do
    { 'f' => { 'author' => 'u', 'text' => 't', 'exp' => Date.today.to_s } }
  end

  after do
    # Necessary to keep the notes.yml file intact
    hash = { 'wow' => { 'author' => 'user', 'text' => 'example', 'exp' => 0 } }
    other = { 'badtext' => { 'author' => 'somename', 'text' => 'bad word',
                             'exp' => 0 } }
    File.open('notes.yml', 'w') do |fl|
      fl.write hash.to_yaml.gsub('---', '')
      fl.write other.to_yaml.gsub('---', '')
    end
  end

  it 'note is saved to hash correctly' do
    expect(nm.save_note('auth', ['name', 0, 0], 'text')).to contain_exactly(
      ['wow', { 'author' => 'user', 'text' => 'example', 'exp' => 0 }],
      ['badtext', { 'author' => 'somename', 'text' => 'bad word',
                    'exp' => 0 }]
    )
  end

  it 'return false if name is not valid' do
    expect(nm.save_note('auth', ['Back', 0, 0], 'text')).to be false
  end

  it 'author is saved' do
    nm.save_note('auth', ['name', 0, 0], 'text')
    hash = YAML.load_file('notes.yml')
    expect(hash['name']['author']).to eq 'auth'
  end

  it 'text is saved' do
    nm.save_note('auth', ['name', 0, 0], 'text')
    hash = YAML.load_file('notes.yml')
    expect(hash['name']['text']).to eq 'text'
  end

  it 'exp date is saved' do
    nm.save_note('auth', ['name', '2022-10-15', 0], 'text')
    hash = YAML.load_file('notes.yml')
    expect(hash['name']['exp']).to eq '2022-10-15'
  end

  it 'invalid exp date is not saved' do
    expect(nm.save_note('auth', ['name', 'some-day', 0], 'text')).to be false
  end

  it 'expired notes are auto deleted before second load' do
    nm.save_note('auth', ['name', '2005-01-01', 0], 'text')
    expect(described_class.new(Date.today).list_notes).not_to include('name')
  end

  it 'raises when current date is wrong, but exp date is legal' do
    temp = described_class.new(0)
    expect { temp.vld_exp(0) }.to raise_error(NoMethodError)
  end

  it 'expired notes cleared' do
    File.open('notes.yml', 'a') { |f| f.write thash_o.to_yaml.gsub('---', '') }
    File.open('notes.yml', 'a') { |f| f.write thash_t.to_yaml.gsub('---', '') }
    described_class.new(Date.today)
    expect(YAML.load_file('notes.yml')['n']).to be nil
  end

  it 'expired notes cleared (when date is today)' do
    File.open('notes.yml', 'a') { |f| f.write thash_t.to_yaml.gsub('---', '') }
    File.open('notes.yml', 'a') { |f| f.write thash_f.to_yaml.gsub('---', '') }
    described_class.new(Date.today)
    expect(YAML.load_file('notes.yml')['f']).to be nil
  end

  it 'valid notes spared' do
    File.open('notes.yml', 'a') { |f| f.write thash_o.to_yaml.gsub('---', '') }
    File.open('notes.yml', 'a') { |f| f.write thash_t.to_yaml.gsub('---', '') }
    described_class.new(Date.today)
    expect(YAML.load_file('notes.yml')['m']).not_to be nil
  end

  it 'valid date is passed on (returned)' do
    expect(nm.vld_exp('2018-10-18')).to eq '2018-10-18'
  end

  it 'not a valid date returns false' do
    expect(nm.vld_exp('0-0-0')).to be false
  end

  it 'passes if list of notes equal to values' do
    expect(nm.list_notes).to eq %w[wow badtext]
  end

  it 'passes if notes text matches with string' do
    expect(nm.note_getter('wow')).to eq 'example'
  end

  it 'returns true if note was deleted' do
    expect(nm.delete_note('wow')).to be true
  end

  it 'passes if cleared file does not contain nils' do
    nm.delete_note('wow')
    nm.delete_note('badtext')
    file = 'notes.yml'
    expect(file).not_to has_yml_nils
  end

  it 'passes if deleted notes are not loaded' do
    nm.delete_note('wow')
    hash = YAML.load_file('notes.yml')
    expect(hash).to eq 'badtext' => { 'author' => 'somename',
                                      'text' => 'bad word', 'exp' => 0 }
  end

  it 'passes if particular note does not contain bad word(s)' do
    expect(YAML.load_file('notes.yml')['wow']['text']).not_to has_bad_words
  end

  it 'passes if particular note contain bad word(s)' do
    expect(YAML.load_file('notes.yml')['badtext']['text']).to has_bad_words
  end

  context 'when notes.yml state is tested' do
    before do
      described_class.new(Date.today).delete_note('badtext')
      described_class.new(Date.today).save_note('tst', ['tst', 0, 0], 'tst')
    end

    it 'checks saving' do
      current = 'notes.yml'
      state = 'state-notes.yml'
      expect(current).to is_yml_identical(state)
    end

    it 'checks loading' do
      hash = { 'wow' => { 'author' => 'user', 'text' => 'example',
                          'exp' => 0 },
               'tst' => { 'author' => 'tst', 'text' => 'tst', 'exp' => 0 } }
      expect(YAML.load_file('notes.yml')).to is_data_identical(hash)
    end
  end

  it 'covers yml identical false case' do
    current = 'notes.yml'
    state = 'users.yml'
    expect(current).not_to is_yml_identical(state)
  end

  it 'covers data identical false case' do
    hash = { 'wow' => 'wow' }
    expect(YAML.load_file('notes.yml')).not_to is_data_identical(hash)
  end

  it 'note is preserved if exp is 0' do
    notename = 'tst'
    described_class.new(Date.today).save_note('tst', ['tst', 0, 0], 'tst')
    expect(notename).not_to note_to_be_deleted
  end

  it 'note is deleted if exp is today (or older)' do
    notename = 'tst'
    described_class.new(Date.today).save_note('tst', ['tst', Date.today.to_s,
                                                      0], 'tst')
    expect(notename).to note_to_be_deleted
  end

  it 'note is preserved if author is present' do
    notename = 'tst'
    described_class.new(Date.today).save_note('t@a.com', ['tst', '2099-01-01',
                                                          0], 'tst')
    expect(notename).not_to note_to_be_deleted
  end

  it 'note is deleted if author is dead' do
    notename = 'tst'
    described_class.new(Date.today).save_note('no@.com', ['tst', '2099-01-01',
                                                          0], 'tst')
    expect(notename).to note_to_be_deleted
  end
end
