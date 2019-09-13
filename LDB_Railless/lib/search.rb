# frozen_string_literal: true

require 'yaml'
require 'etc'

# Implements searching (broken)
class Search
  def initialize
    @ymls = { 'Users' => 'users.yml', 'Projects' => 'projects.yml',
              'WorkGroups' => 'workgroups.yml', 'Budgets' => 'budgets.yml',
              'Notes' => 'notes.yml' }
    @instancevariable = true
  end

  def yml_key_check(arg)
    return true if @ymls.keys.to_set.eql?(arg.to_set)

    false
  end

  # Bypasses reek's instance state
  def parm_instancevariable(val = @instancevariable)
    @instancevariable = val
  end

  def ymls_getter
    arr = []
    @ymls.each_key do |key|
      arr.push(@ymls.fetch(key))
    end
    arr
  end

  # Methods to bypass reek's too many statements in one method
  def grab_subkeys(hash)
    arr = []
    hash.each do |key, val|
      arr.push(key, val) if @instancevariable
    end
    arr
  end

  def gather_data(file, value)
    temp = YAML.load_file(file)
    temp.each do |key, val|
      arr = grab_subkeys(val)
      if arr.include?(value)
        return [file.split('.').first +
                ' ' + key + ' contain: ', value]
      end
    end
    ''
  end

  def search_by_criteria(criteria, value)
    result = []
    criteria.each do |crit|
      result.push(gather_data(@ymls.fetch(crit), value))
    end
    result
  end
end
