# frozen_string_literal: true

require 'securerandom' # random hash kuriantis metodas yra
require 'uri'
require './application_record'
require 'mail'

# Documentation about class User
class Provider < ApplicationRecord
  def all_names
    return false unless name

    arr = []
    Provider.all.each do |prov|
      arr.push(prov.name)
    end
    arr
  end

  def offers?
    return true if ProvidedMaterial.find_by(name: name)

    false
  end

  def qty?
    list = ProvidedMaterial.where(name: name)
    list.each do |el|
      return false unless el.unit.to_f.positive?
    end
    true
  end

  def materials_by_provider
    return false unless qty? && offers?

    arr = []
    ProvidedMaterial.where(name: name).each do |mat|
      arr.push(mat.material)
    end
    arr
  end
end
