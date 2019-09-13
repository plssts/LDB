# frozen_string_literal: true

# Manages project data control
class ProjectsController < ApplicationController
  def index
    @projects = Project.where(manager: current_user['email'])
  end

  def addmem
    otherparams = params
    return unless otherparams.key?(:project)

    Project.find_by(id: params.fetch(:id))
           .add_member(params.fetch(:project).fetch(:member))
  end

  def create
    return unless params.key?(:project)

    @hash = params.fetch(:project)
    Project.create(name: @hash.fetch(:name),
                   manager: @hash.fetch(:manager),
                   status: @hash.fetch(:status),
                   budget: @hash.fetch(:budget))
  end

  def bdgts
    @proj = params.fetch(:project)
    BudgetManager.new.budgets_setter(@proj.fetch(:id), @proj.fetch(:budget))
  end

  def stts_nm_mngr(pro)
    @proj = params.fetch(:project)
    pro.project_status_setter(@proj.fetch(:status))
    pro.name = @proj.fetch(:name)
    pro.manager = @proj.fetch(:manager)
    bdgts
  end

  def update
    return unless params.key?(:project)

    pro = Project.find_by(id: params.fetch(:project).fetch(:id))
    stts_nm_mngr(pro)
    pro.save
  end

  def destroy
    Project.find_by(id: params.fetch(:id)).destroy
  end
end
