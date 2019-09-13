# frozen_string_literal: true

# handles materials
class MaterialsController < ApplicationController
  def index
    @materials = ProvidedMaterial.all
    @providers = Provider.all
  end

  def addof
    return unless params.key?(:material)

    @materials = params.fetch(:material)
    ProvidedMaterial.create(name: @materials.fetch(:name),
                            material: @materials.fetch(:material),
                            unit: @materials.fetch(:unit),
                            ppu: @materials.fetch(:ppu))
  end

  def remof
    ProvidedMaterial.find_by(id: params.fetch(:id)).destroy
  end

  def addprov
    return unless params.key?(:material)

    Provider.create(name: params.fetch(:material).fetch(:name))
  end

  def remprov
    Provider.find_by(id: params.fetch(:id)).destroy
  end
end
