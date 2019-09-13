# frozen_string_literal: true

require_relative '../rails_helper'

describe SearchController do
  include Devise::Test::ControllerHelpers
  render_views

  let(:all_params) do
    { proj: 'Project', wgs: 'WorkGroup', usr: 'User', 'tsk': 'Task',
      note: 'NotesManager', ordr: 'Order',
      search: { value: 'Tomas' } }
  end

  it do
    get :show, params: all_params
    out = response.body.match?('User has:  Tomas') &&
          response.body.match?('Project has:  Tomas')
    expect(out).to be true
  end

  it do
    get :show, params: { tsk: 'Task', search: { value: 'finish something' } }
    out = response.body.match?('Task has:  finish something')
    expect(out).to be true
  end

  it do
    get :show, params: { note: 'NotesManager', search: { value: 'Uzrasas3' } }
    out = response.body.match?('NotesManager has:  Uzrasas3')
    expect(out).to be true
  end

  it do
    get :show, params: { ordr: 'Order', search: { value: 'U7856Y11A13HH1L' } }
    out = response.body.match?('Order has:  U7856Y11A13HH1L')
    expect(out).to be true
  end

  it do
    get :show, params: { wgs: 'WorkGroup', search: { value: 'Antra grupe' } }
    out = response.body.match?('WorkGroup has:  Antra grupe')
    expect(out).to be true
  end

  it 'covers -unless mutation in gathering' do
    expect { get :show }.not_to raise_error(NoMethodError)
  end
end
