# frozen_string_literal: true

require './application_record'
require 'etc'

# rubocop comment?
class Search
  def initialize
    @state = true
  end

  def stater(val = @state)
    @state = val
  end

  def gather_data(modl, value)
    modlo = modl
    modlclass = modlclasso = modl.constantize
    modlclass.column_names.each do |cl|
      if modlclasso.where("#{cl} LIKE ?", value).take && @state
        return [modlo + ' has: ', value]
      end
    end
    ''
  end

  def search_by_criteria(criteria, value)
    result = []
    return result if [nil].include?(value)

    criteria.each do |modl|
      result.push(gather_data(modl, value))
    end
    result
  end
end
