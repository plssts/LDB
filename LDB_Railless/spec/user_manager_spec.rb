# frozen_string_literal: true

require 'simplecov'
SimpleCov.start

require_relative '../lib/user'
require_relative '../lib/user_manager'
require_relative 'custom_matcher'

describe UserManager do
  after do
    # Necessary to keep the users.yml file intact
    hash = { 't@a.com' => { 'name' => 'tomas', 'lname' => 'genut',
                            'pwd' => '123' } }
    File.open('users.yml', 'w') { |fl| fl.write hash.to_yaml.gsub('---', '') }
  end

  before do
    hash = {}
    File.open('online.yml', 'w') { |fl| fl.write hash.to_yaml.gsub('---', '') }
  end

  it 'marks start to online correctly' do
    described_class.new.mark_login('t@a.com')
    expect(YAML.load_file('online.yml')['t@a.com']['start'])
      .to be_instance_of(Time)
  end

  it 'marks end to online correctly' do
    described_class.new.mark_login('t@a.com')
    expect(YAML.load_file('online.yml')['t@a.com']['end']).to eq 0
  end

  it 'online file is clear' do
    described_class.new.mark_login('t@a.com')
    file = 'online.yml'
    expect(file).not_to has_yml_nils
  end

  it 'mutant sometimes writes class instance to file' do
    expect(described_class.new.mark_login(described_class.new)).to be false
  end

  it 'mutant sometimes writes nil to file' do
    expect(described_class.new.mark_login(nil)).to be false
  end

  it 'unregistered user should not be able to login' do
    e = 't@t.com'
    expect(described_class.new.login(e, '123')).to be false
  end

  it 'user is actually deleted in file' do
    described_class.new.register(User.new(email: 'aa.com'))
    described_class.new.delete_user(User.new(email: 't@a.com'))
    hash = YAML.load_file('users.yml')
    expect(hash['t@a.com']).to be nil
  end

  it 'pass is actually written when registering' do
    described_class.new.register(User.new(email: 'de@mo.com'))
    hash = YAML.load_file('users.yml')
    expect(hash['de@mo.com']['pwd']).to eq '123'
  end

  it 'email is actually written when registering' do
    described_class.new.register(User.new(email: 'de@mo.com'))
    hash = YAML.load_file('users.yml')
    expect(hash.key?('de@mo.com')).to be true
  end

  it 'name is actually written when registering' do
    described_class.new.register(User.new(name: 'neim',
                                          email: 'de@mo.com'))
    hash = YAML.load_file('users.yml')
    expect(hash['de@mo.com']['name']).to eq 'neim'
  end

  it 'l name is actually written when registering' do
    described_class.new.register(User.new(last_name: 'lastname',
                                          email: 'de@mo.com'))
    hash = YAML.load_file('users.yml')
    expect(hash['de@mo.com']['lname']).to eq 'lastname'
  end

  it 'file is cleared of {} and --- on deletion' do
    user = User.new(name: 'tomas', last_name: 'genut', email: 't@a.com')
    described_class.new.delete_user(user)
    file = 'users.yml'
    expect(file).not_to has_yml_nils
  end

  it 'does not crash hash[key] as empty file' do
    user = User.new(name: 'tomas', last_name: 'genut', email: 't@a.com')
    described_class.new.delete_user(user)
    expect(described_class.new.register(user)).to be true
  end

  it 'user is actually deleted' do
    user = User.new(name: 'tomas', last_name: 'genut', email: 't@a.com')
    described_class.new.delete_user(user)
    expect(File.read('users.yml').match?(/---/)).to be false
  end

  it 'file is cleared of three dashes on creation' do
    user = User.new(name: 'tomas', last_name: 'genut', email: 't@a.com')
    described_class.new.register(user)
    expect(File.read('users.yml').match?(/---/)).to be false
  end

  it 'new user is blocked with existing email' do
    expect(described_class.new.users_push('t@a.com', {})).to be false
  end

  it 'initial current user is a nil hash' do
    hsh = {}
    expect(described_class.new.current_user_getter).to eq hsh
    # rubocop supposes to switch to {} - which fails
  end

  it 'existing user cannot register again' do
    e = 't@a.com'
    v1 = described_class.new
    expect(v1.register(User.new(email: e))).to be false
  end

  it 'user1 should be equal to user1' do
    e = 'ee@a.com'
    user = User.new(name: 'tomas', last_name: 'genut', email: e)
    v1 = described_class.new
    expect(v1.register(user)).to be true
  end

  it 'deleting existing user' do
    e = 't@a.com'
    v1 = described_class.new
    expect(v1.delete_user(User.new(email: e))).to be true
  end

  # TODO: active project checking will be implemented later

  it 'three dashes are cleared' do
    e = 'ee@a.com'
    user = User.new(name: 'tomas', last_name: 'genut', email: e)
    described_class.new.register(user)
    expect(File.read('users.yml').match?(/---/)).to be false
  end

  it 'to hash works right' do
    e = 't@a.com'
    expect(described_class.new.to_hash(e)).to eq e => { 'name' => 'tomas',
                                                        'lname' => 'genut',
                                                        'pwd' => '123' }
  end

  context 'when users.yml state is tested' do
    before do
      user = User.new(name: 'tst', last_name: 'tst', email: 'tst')
      user.password_set('tst')
      described_class.new.register(user)
      described_class.new.delete_user(User.new(email: 't@a.com'))
    end

    it 'checks saving' do
      current = 'users.yml'
      state = 'state-users.yml'
      expect(current).to is_yml_identical(state)
    end

    it 'checks loading' do
      hash = { 'tst' => { 'name' => 'tst', 'lname' => 'tst', 'pwd' => 'tst' } }
      expect(YAML.load_file('users.yml')).to is_data_identical(hash)
    end
  end

  context 'when user tries to login' do
    it 'registered user should be able to login' do
      e = 't@a.com'
      expect(described_class.new.login(e, '123')).to be true
    end

    it 'not be able to login when email is invalid' do
      expect(described_class.new.login('erhearhaerh', '123')).to be false
    end

    it 'not be able to login when password is invalid' do
      expect(described_class.new.login('t@a.com', '45')).to be false
    end

    it 'when email is nil should fail' do
      expect(described_class.new.login(nil, '123')).to be false
    end

    it 'when password is nil should fail' do
      expect(described_class.new.login('t@a.com', nil)).to be false
    end

    it 'if no params, shoul fail' do
      expect(described_class.new.login(nil, nil)).to be false
    end
  end

  context 'when user password is being changed' do
    it 'complete if everything is right' do
      dc = described_class.new
      e = 'bubu@gmail.com'
      dc.register(User.new(email: e, pass: '4535'))
      expect(described_class.new.save_user_password(e, '445')).to be true
    end

    it 'fail if invalid password' do
      e = 't@a.com'
      expect(described_class.new.save_user_password(e, '120')).to be true
    end

    it 'if email is nil should fail' do
      expect(described_class.new.save_user_password(nil, '124')).to be false
    end

    it 'if password is nil should fail' do
      expect(described_class.new.save_user_password('t@a.com', nil)).to be false
    end

    it 'fails if user does not exist' do
      expect(described_class.new.save_user_password('wegwah', '12')).to be false
    end

    it 'no params fail' do
      expect(described_class.new.save_user_password(nil, nil)).to be false
    end

    it 'saves user password correctly' do
      e_f = { 't@a.com' => { 'name' => 'tomas', 'lname' => 'genut',
                             'pwd' => '120' } }
      described_class.new.save_user_password('t@a.com', '120')
      r_f = YAML.load_file('users.yml')
      expect(e_f.eql?(r_f)).to be true
    end

    it 'fails on non-string mail' do
      expect(described_class.new.users_push(45, 'mail' => {})).to be false
    end

    it 'user password is actually updated' do
      e_f = described_class.new.to_hash('t@a.com')
      described_class.new.save_user_password('t@a.com', 'p@ssw*rd')
      r_f = described_class.new.to_hash('t@a.com')
      expect(e_f.eql?(r_f)).not_to be true
    end

    it 'corrently edits user var' do
      e_f = { 't@a.com' => { 'name' => 'tomas', 'lname' => 'genut',
                             'pwd' => '100' } }
      dc = described_class.new
      dc.save_user_password('t@a.com', '100')
      expect(e_f.eql?(dc.users_getter)).to be true
    end
  end

  it 'not pops when email doesn\'t exist' do
    expect(described_class.new.users_pop('aaaaa')).to be false
  end

  it 'pops when email exists' do
    expect(described_class.new.users_pop('t@a.com')).to be true
  end

  it 'doesn\'t hash if email doesn\'t exist' do
    expect(described_class.new.to_hash('agaegwaeg')).to be false
  end

  it 'does hash if email exists' do
    expect(described_class.new.to_hash('t@a.com').class.eql?(Hash)).to be true
  end
end
