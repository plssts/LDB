# frozen_string_literal: true

require_relative '../rails_helper'

describe WelcomeController do
  it 'covers mutation +super' do
    expect_any_instance_of(ApplicationController).not_to receive(:initialize)
    get :index
  end
end
