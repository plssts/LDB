# frozen_string_literal: true

require 'date'
require 'etc'
require_relative 'project'
require 'yaml'

# Manages user notes
class NotesManager
  def initialize(date)
    @notes = YAML.load_file('notes.yml')
    @exp_temp = date
    clr_exp.each { |nm| delete_note(nm) }
  end

  def clr_exp
    names = []
    @notes.each_key do |key|
      exp = @notes.fetch(key).fetch('exp')
      names.push(key) if !exp.equal?(0) && Date.strptime(exp) <= Date.today
    end
    names
  end

  def vld_exp(expire)
    expireo = expire # So it doesn't refer to 'expire' too much
    return true if [0].include?(expire) && @exp_temp.eql?(Date.today)

    yr, mt, dy = expireo.split('-')
    return expire if Date.valid_date? yr.to_i, mt.to_i, dy.to_i

    false
  end

  def save_note(author, n_and_e, text)
    # 4 arguments are not allowed, so 2nd is array '[name, expire]'
    # Always pass extra 0 as 3rd element to counter mutation '.fetch(-1)'
    return false if (nm = n_and_e.fetch(0)).equal?('Back') ||
                    !vld_exp(ex = n_and_e.fetch(1))

    hash = { nm => { 'author' => author, 'text' => text,
                     'exp' => ex } }
    File.open('notes.yml', 'a') { |fl| fl.write hash.to_yaml.sub('---', '') }
    @notes
  end

  def list_notes
    arr = []
    @notes.each_key do |key|
      arr.push(key)
    end
    arr
  end

  def note_getter(name)
    @notes.fetch(name).fetch('text')
  end

  def delete_note(name)
    @notes.delete(name)
    File.open('notes.yml', 'w') do |fl|
      fl.write @notes.to_yaml.sub('---', '').sub('{}', '')
    end
    true
  end
end
