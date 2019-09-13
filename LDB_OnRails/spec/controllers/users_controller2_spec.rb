# frozen_string_literal: true

require_relative '../rails_helper'

describe UsersController do
  include Devise::Test::ControllerHelpers
  render_views

  let(:upd_hash) do
    { user: { email: 'tg@gmail.com', pass: '-4',
              name: 'nn', lname: 'nl' } }
  end

  it 'renders correct default value fill-ins' do
    sign_in(User.find_by(email: 'tg@gmail.com'))
    get :index, params: { method: 'edit' }
    expect(response.body).to match('Email: tg@gmail.com')
  end
end
