# frozen_string_literal: true

require_relative '../rails_helper'

describe MaterialsController do
  include Devise::Test::ControllerHelpers
  render_views

  it 'renders providers in page' do
    get :index
    out = response.body.match?('Choppers') &&
          response.body.match?('SteelPool') &&
          response.body.match?('WoodWorks')
    expect(out).to be true
  end

  it 'renders offers in page' do
    get :index
    out = response.body.match?('WoodWorks Planks 30000 10.0') &&
          response.body.match?('Choppers Planks 350 20.0') &&
          response.body.match?('WoodWorks Boards 5000 15.5')
    expect(out).to be true
  end
end
