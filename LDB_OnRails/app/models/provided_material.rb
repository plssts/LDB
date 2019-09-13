# frozen_string_literal: true

require 'securerandom' # random hash kuriantis metodas yra
require 'uri'
require './application_record'
require 'mail'

# Documentation about class User
class ProvidedMaterial < ApplicationRecord
  # On order creation
  # find_by(provider, material)
  def deduct_qty(qty)
    self.unit = unit.to_f - qty
    save
  end

  # On order deletion
  def add_qty(qty)
    self.unit = unit.to_f + qty
    save
  end
end
