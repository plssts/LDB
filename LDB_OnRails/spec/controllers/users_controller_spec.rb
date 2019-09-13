# frozen_string_literal: true

require_relative '../rails_helper'

describe UsersController do
  include Devise::Test::ControllerHelpers

  let(:uc) do
    uc = described_class
    allow_any_instance_of(uc).to receive(:find_and_login).and_return(true)
    # raises 'ActionController::UnknownFormat' otherwise
    uc
  end

  let(:upd_hash) do
    { user: { email: 'ar@gmail.com', pass: '-4',
              name: 'nn', lname: 'nl' } }
  end

  let(:cre_hash) do
    { user: { email: 'new@g.com', pass: '-4',
              name: 'nn', lname: 'nl' } }
  end

  let(:login_hash) do
    { user: { email: 'ar@gmail.com', pass: 'p4ssw1rd' } }
  end

  it 'present user params enable registering check' do
    expect_any_instance_of(UserManager).to receive(:register)
    get :create, params: cre_hash
  end

  it 'empty user params do not' do
    expect_any_instance_of(UserManager).not_to receive(:register)
    get :create
  end

  it 'signs user in if credentials are valid' do
    hash = { 'user' => { 'email' => 'tg@gmail.com', 'pass' => 'p4ssw0rd' } }
    expect_any_instance_of(uc).to receive(:find_and_login)
    post :parse_login, params: hash
  end

  it 'signing in is skipped otherwise' do
    hash = { 'user' => { 'email' => 'doesnot', 'pass' => 'exist' } }
    expect_any_instance_of(uc).not_to receive(:find_and_login)
    post :parse_login, params: hash
  end

  it 'updates user information' do
    sign_in(User.find_by(email: 'ar@gmail.com'))
    post :update, params: upd_hash
    usr = User.find_by(email: 'ar@gmail.com')
    expect(usr.name.eql?('nn') && usr.lname.eql?('nl') && usr.pass.eql?('-4'))
      .to be true
  end

  context 'when creating user' do
    subject(:subj) { described_class.new }

    before do
      allow_any_instance_of(described_class).to receive(:params)
        .and_return(cre_hash)
      # has a valid user to create
      allow_any_instance_of(UserManager).to receive(:login).and_return(true)
      # temporarily stub login to check find_and_login call
    end

    it 'creates user' do
      post :create
      usr = User.find_by(email: 'new@g.com')
      expect(usr.name.eql?('nn') && usr.lname.eql?('nl') &&
             usr.pass.eql?('-4'))
        .to be true
    end

    it 'rejects signing in with wrong params' do
      out = subj.send(:find_and_login)
      expect(out).to be false
    end

    it 'returns false with nonexisting user' do
      out = subj.send(:parse_login)
      expect(out).to be false
    end
  end

  it 'deletes user' do
    sign_in(User.find_by(email: 'tg@gmail.com'))
    post :destroy
    usr = User.find_by(email: 'tg@gmail.com')
    expect(usr).to be nil
  end

  it 'covers mutation +super' do
    expect_any_instance_of(ApplicationController).not_to receive(:initialize)
    get :show
  end
end
