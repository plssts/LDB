# frozen_string_literal: true

require './application_record'
require 'project_manager'

# Creates graphs
class Graph
  def initialize
    @calc_average = true
  end

  def calc_val(val = @calc_average)
    @calc_average = val
  end

  def create_projects_and_members_graph(prj_mngr)
    sum = 0
    (hsh = prj_mngr.gen_projects_and_members_hash).each_value do |val|
      sum += val if @calc_average
    end
    [hsh.max_by(&:last).last, sum, hsh]
  end
end
