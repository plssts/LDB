# frozen_string_literal: true

# yaml files have no triple dashes, empty hashes
# user_manager_spec::56
RSpec::Matchers.define :has_yml_nils do
  match do |check|
    File.open check do |file|
      file.find do |line|
        return true if line.match?(/\{\}/) || line.match?(/---/)
      end
    end
    return false
  end
end

# Checks whether the project (by id) has positive budget
# budget_manager_spec::69
RSpec::Matchers.define :project_budget_positive do
  match do |budget|
    file = YAML.load_file('budgets.yml')
    return true if file.fetch(budget).fetch('budget').positive?

    return false
  end
end

# Specified password should have at least a number and a special character
# user_spec.rb::96
RSpec::Matchers.define :has_advanced_password do
  match do |string|
    if string.match?(/\d/)
      return true unless [nil].include?(
        string.index(/[\+\-\!\@\#\$\%\^\&\*\(\)]/)
      )
    end
    return false
  end
end

# A note should not have any bad words entered
# notes_manager_spec::62
RSpec::Matchers.define :has_bad_words do
  match do |text|
    badlist = %w[bad\ word other\ bad\ word really\ bad\ word]
    badlist.any? { |word| return true if text.include?(word) }
    return false
  end
end

# A key is unique in .yml file
# work_group_manager_spec::38
RSpec::Matchers.define :is_key_unique do |actual|
  count = []
  match do |expected|
    File.open(actual).each do |line|
      count.push('+') if line
                         .split(':')
                         .first.start_with?('\'' + expected.to_s + '\'')
    end
    return false if count.length > 1

    return true
  end
end

# Files are identical (for state testing) when SAVING
# work_group_manager_spec::88
RSpec::Matchers.define :is_yml_identical do |actual|
  match do |expected|
    hash1 = YAML.load_file(actual)
    hash2 = YAML.load_file(expected)
    return true if hash1.eql?(hash2)

    false
  end
end

# Data is identical (for state testing) when LOADING
# work_group_manager_spec::92
RSpec::Matchers.define :is_data_identical do |actual|
  match do |expected|
    expected.each do |key, value|
      return false unless actual.fetch(key).eql?(value)
    end
    true
  end
end

# Specific case for unique budget keys
# budget_manager_spec::65
RSpec::Matchers.define :no_duplicate_budgets do |actual|
  count = []
  match do |expected|
    File.open(actual).each do |line|
      count.push('+') if line.split(':').first.start_with?(expected)
    end
    return false if count.length > 1

    return true
  end
end

# Hash should exist in a file and be identical to object's hash
# work_group_manager_spec.rb::32
RSpec::Matchers.define :be_correctly_saved do |actual|
  match do |expected|
    return false unless (file = YAML.load_file(actual))
    return false unless file.key?(expected.keys[0])
    return false unless expected.values[0] == file[expected.keys[0]]

    return true
  end
end
