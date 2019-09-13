# frozen_string_literal: true

require_relative '../rails_helper'

describe OrdersController do
  include Devise::Test::ControllerHelpers
  render_views

  before do
    allow_any_instance_of(described_class).to receive(:current_user)
      .and_return('email' => 'Tomas')
    # Cannot use sign_in since Tomas does not actually exist
  end

  it 'renders orders in page' do
    get :index
    out = response.body.match?('|Order id: 15| 2018-08-05 00:00:00 UTC 100.0'\
                               ' WoodWorks 0.0 U8856SPPA131310') &&
          response.body.match?('Choppers 0.0 U8856SPPA131310')
    expect(out).to be true
  end

  it do
    get :index
    arr = []
    assigns(:my_orders).each { |o| o.each { |ord| arr.push(ord.material) } }
    expect(arr).to eq %w[Planks Planks Supports]
  end
end
