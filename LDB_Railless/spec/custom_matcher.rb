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

# Check if all users have known (expected) email domains
# user_spec.rb::116
RSpec::Matchers.define :users_domain_legit do
  arr = []
  match do |expected|
    file = YAML.load_file('users.yml')
    file.each_key do |key|
      arr.push(key) unless expected.include?(key.partition('@').last)
    end
    return false if arr.size.positive?

    true
  end
end

# Check if a note is going to be deleted on next startup
# notes_manager_spec::127
RSpec::Matchers.define :note_to_be_deleted do
  # Should delete the note if the author doesn't exist anymore or
  # the date has passed
  match do |expected|
    file = YAML.load_file('notes.yml')
    file.each_key do |key|
      next unless key.eql?(expected)

      date = file.fetch(key).fetch('exp')
      return false if date == 0
      return true if Date.parse(date) <= Date.today

      users = YAML.load_file('users.yml')
      return false if users[file.fetch(key).fetch('author')]

      true
    end
  end
end

# Check if the whole system has necessary information to function
# project_spec::182
RSpec::Matchers.define :files_ready do
  match do |expected|
    if expected == true # Validate if each is not empty as well
      files = %w[budgets.yml notes.yml projects.yml users.yml workgroups.yml]
      files.each do |file|
        return false if YAML.load_file(file) == false
      end
      true
    else
      File.file?('budgets.yml') && File.file?('notes.yml') &&
        File.file?('projects.yml') && File.file?('users.yml') &&
        File.file?('workgroups.yml')
    end
  end
end
