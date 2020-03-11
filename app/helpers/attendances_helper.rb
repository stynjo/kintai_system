# frozen_string_literal: true

module AttendancesHelper
  def attendance_state(attendance)
    if Date.current == attendance.worked_on
      return '出勤' if attendance.started_at.nil?
      return '退勤' if attendance.started_at.present? && attendance.finished_at.nil?
    end
    false
  end

  def working_times(start, finish)
    format('%.2f', (((finish.floor_to(15.minutes) - start.floor_to(15.minutes)) / 60)) / 60.0)
  end

  def over_working_times(over, finish)
    format('%.2f', (((over.floor_to(15.minutes) - finish.floor_to(15.minutes)) / 60)) / 60.0)
  end
end
