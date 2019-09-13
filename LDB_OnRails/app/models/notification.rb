# frozen_string_literal: true

require 'uri'
require './application_record'
require 'mail'

# Documentation about class User
class Notification < ApplicationRecord
  def senders_getter
    # gets by self.recvr
    arr = []
    list = Notification.where(recvr: recvr)
    list.each do |el|
      arr.push(el.sendr)
    end
    arr
  end

  def edit_message(send, rec, new)
    return false if [nil].include?(sendr)

    notif = Notification.find_by(sendr: send, recvr: rec)
    notif.msg = new
    notif.save
    msg
  end

  def read_message(sendd, rec)
    return false if [nil].include?(sendr)

    notif = Notification.find_by(sendr: sendd, recvr: rec)
    truncate_read(sendd, rec)
    notif.msg
  end

  def truncate_read(send, recc)
    return false if [nil].include?(recvr)

    msg = Notification.find_by(sendr: send, recvr: recc)
    return false unless msg

    msg.destroy
  end
end
