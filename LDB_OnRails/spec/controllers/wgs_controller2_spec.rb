# frozen_string_literal: true

require_relative '../rails_helper'

describe WgsController do
  include Devise::Test::ControllerHelpers
  render_views
  fixtures :all

  let(:upd_hash) do
    { user => { email: 'tg@gmail.com', pass: '-4',
                name: 'nn', lname: 'nl' } }
  end

  it 'renders hidden id to pass later' do
    get :addmem
    expect(response.body)
      .to match('input type=\"hidden\" name=\"id\" id=\"id\"')
  end

  it 'actually loads managed workgroups' do
    sign_in(User.find_by(email: 'ar@gmail.com'))
    get :index
    expect(response.body).to match('|Project id: 201050| Trecia grupe 10.0')
  end

  it 'covers mutation current_user[nil/self]' do
    sign_in(User.find_by(email: 'ar@gmail.com'))
    get :index
    expect(response.body).not_to match('nilly 10.0')
  end

  it 'project is not set to nil when it is not supposed to' do
    sign_in(User.find_by(email: 'ar@gmail.com'))
    get :index
    expect(assigns(:projects)).not_to be nil
  end

  it 'no user raises error' do
    expect { get :index }.to raise_error(NoMethodError)
  end

  it 'different user renders different workgroups' do
    allow_any_instance_of(described_class).to receive(:current_user)
      .and_return(email: 'Tomas')
    # Cannot use sign_in since Tomas does not actually exist
    get :index
    expect(response.body).to match('|Project id: 101050| Trecia grupe 10.0')
  end
end
