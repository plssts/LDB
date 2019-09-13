# frozen_string_literal: true

# handles searching
class SearchController < ApplicationController
  def show
    crit = []
    all = %w[usr proj wgs tsk note ordr]
    all.each do |val|
      crit.push(params.fetch(val)) unless [nil].include?(params[val])
    end
    @result = Search.new.search_by_criteria(crit, params.fetch(:search)
                                                        .fetch(:value))
  end
end
