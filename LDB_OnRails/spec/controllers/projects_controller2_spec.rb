# frozen_string_literal: true

require_relative '../rails_helper'

describe ProjectsController do
  include Devise::Test::ControllerHelpers
  render_views

  it 'renders form only' do
    get :create
    expect(response.body).to match('"submit" name="commit" value="Create"')
  end

  it 'sets the variable on page loading' do
    sign_in(User.find_by(email: 'ar@gmail.com'))
    get :index
    expect(assigns(:projects)).not_to be nil
  end

  it 'actually loads projects' do
    sign_in(User.find_by(email: 'ar@gmail.com'))
    get :index
    expect(response.body).to match('|201050| act8 In progress 200.0')
  end

  it 'covers mutation manager: nil/"" ' do
    sign_in(User.find_by(email: 'ar@gmail.com'))
    get :index
    expect(assigns(:projects).first.name).to eq 'act8'
  end
end
