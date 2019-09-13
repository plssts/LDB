# frozen_string_literal: true

# handles workgroups
class WgsController < ApplicationController
  def index
    @projects = Project.where(manager: current_user['email'])
  end

  def create
    return unless params.key?(:wg)

    (@projects = params.fetch(:wg)) &&
      (prid = @projects.fetch(:projid))
    WorkGroup.create(projid: prid, name: @projects.fetch(:name), budget: 0)
    wgr = WorkGroup.find_by(projid: prid)
    wgr.project_budget_setter(@projects.fetch(:budget).to_f)
  end

  def addtsk
    WorkGroup.find_by(id: params.fetch(:id))
             .add_group_task(params.fetch(:wg).fetch(:task))
  end

  def remtsk
    WorkGroup.find_by(id: params.fetch(:id))
             .remove_group_task(params.fetch(:task))
  end

  def addmem
    return unless params.key?(:wg)

    WorkGroup.find_by(id: params.fetch(:id))
             .add_group_member(params.fetch(:wg).fetch(:member))
  end

  def remmem
    WorkGroup.find_by(id: params.fetch(:id))
             .remove_group_member(params.fetch(:member))
  end

  def destroy
    wgid = params.fetch(:id)
    @projects = WorkGroup.find_by(id: wgid)
    @projects.project_budget_setter(0)
    @projects.destroy
  end
end
