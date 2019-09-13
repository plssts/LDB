# frozen_string_literal: true

require 'uri'
require './application_record'
require 'mail'

# Documentation about class User
class Order < ApplicationRecord
  def valid_cost
    pm = ProvidedMaterial.find_by(name: provider, material: material)
    return false unless cost.equal?(pm.ppu * qty)

    true
  end

  def deduct_budget(value, bmanager)
    proj = Project.find_by(id: id = projid)
    return false unless bmanager.can_deduct_more(value, id) &&
                        ![nil].include?(vat) && valid_cost

    proj.budget -= value
    proj.save
    true
  end

  def order_received
    destroy
  end

  # If the order is cancelled
  def restore_budget
    bm = BudgetManager.new
    pid = projid
    oldb = Project.find_by(id: pid).budget
    bm.budgets_setter(pid, oldb + cost)
    order_received
  end
end
