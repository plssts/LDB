# frozen_string_literal: true

require_relative '../rails_helper'

describe UsersController do
  include Devise::Test::ControllerHelpers
  fixtures :all

  let(:login_hash) do
    { user: { email: 'ar@gmail.com', pass: 'p4ssw1rd' } }
  end

  before do
    allow_any_instance_of(described_class).to receive(:params)
      .and_return(login_hash)
    # has a valid user to login
  end

  it 'accepts login attempt' do
    out = controller.find_and_login
    expect(out).to be true
  end

  it 'actually signs the user in' do
    controller.find_and_login
    expect(controller.current_user[:email]).to eq 'ar@gmail.com'
  end
end
