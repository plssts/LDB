# frozen_string_literal: true

# manages orders
class OrdersController < ApplicationController
  def index
    @my_orders = []
    projs = Project.where(manager: current_user.fetch('email'))
    projs.each do |proj|
      @my_orders.push(Order.where(projid: proj))
    end
  end

  def create
    return unless params.key?(:order)

    @hash = params.fetch(:order)
    (mat = @hash.fetch(:material)) &&
      (prov = @hash.fetch(:provider)) &&
      (@qty = @hash.fetch(:qty)) &&
      (fqty = @qty.to_f)
    cr_call(mat, prov, fqty)
    ProvidedMaterial.find_by(name: prov, material: mat).deduct_qty(fqty)
  end

  def cr_call(mat, prov, fqty)
    Order.create(date: Time.current, cost: params.fetch(:ppu).to_f * fqty,
                 provider: prov, vat: @hash.fetch(:vat),
                 recvaccount: @hash.fetch(:recvaccount),
                 contactname: @hash.fetch(:contactname), qty: @qty,
                 unit: @hash.fetch(:unit), material: mat,
                 projid: @hash.fetch(:projid))
  end

  def destroy
    @ordr = Order.find_by(id: params.fetch(:id))
    unless params.key?(:comp)
      ProvidedMaterial.find_by(name: @ordr.provider, material: @ordr.material)
                      .add_qty(@ordr.qty)
    end
    @ordr.destroy
  end
end
