# frozen_string_literal: true

# controls members of projects
class ProjmemsController < ApplicationController
  def index
    ProjectMember.find_by(projid: params.fetch(:id),
                          member: params.fetch(:member)).destroy
  end
end
