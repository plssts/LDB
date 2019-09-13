# frozen_string_literal: true

require_relative '../rails_helper'

describe TasksController do
  include Devise::Test::ControllerHelpers
  render_views

  it 'renders correct tasks' do
    get :index
    out = response.body.match?('finish something') &&
          response.body.match?('do not read this')
    expect(out).to be true
  end
end
