# frozen_string_literal: true

require 'csv'
require 'date'

CSV.generate do |csv|
  column_name = %w[日付 出勤時間 退勤時間]
  csv << column_name
  @attendances.each do |attendance|
    column_values = [
      attendance.worked_on.strftime('%Y年%-m月%^d日'),
      if attendance.started_at.present? && attendance.edit_started_at.nil?
        attendance.started_at.strftime('%R')
      elsif attendance.edit_started_at.present?
        attendance.edit_started_at.strftime('%R')
      end,
      if attendance.finished_at.present? && attendance.edit_finished_at.nil?
        attendance.finished_at.strftime('%R')
      elsif attendance.edit_finished_at.present?
        attendance.edit_finished_at.strftime('%R')
      end
    ]
    csv << column_values
  end
end
