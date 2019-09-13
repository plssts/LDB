# frozen_string_literal: true

# handles tasks
class TasksController < ApplicationController
  def index
    @tasks = Task.all
  end

  def create
    Task.create(task: params.fetch(:task).fetch(:task)) if params.key?(:task)
  end

  def destroy
    Task.find_by(task: params.fetch(:task)).destroy
  end
end
