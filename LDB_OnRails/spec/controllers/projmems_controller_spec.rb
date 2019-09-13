# frozen_string_literal: true

require_relative '../rails_helper'

describe ProjmemsController do
  it do
    get :index, params: { id: 101_050, member: 'guy@mail.com' }
    expect(ProjectMember.find_by(projid: 101_050, member: 'guy@mail.com'))
      .to be nil
  end
end
