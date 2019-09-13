# frozen_string_literal: true

require_relative '../rails_helper'

describe TasksController do
  include Devise::Test::ControllerHelpers

  it 'VIEWS TEST: create renders view' do
    post :create
    expect(response).to render_template(:create)
  end

  it 'task is actually created' do
    post :create, params: { task: { task: 'naujas' } }
    expect(Task.find_by(task: 'naujas')).not_to be nil
  end

  it 'task is actually deleted' do
    post :destroy, params: { task: 'do not read this' }
    expect(Task.find_by(task: 'do not read this')).to be nil
  end
end
