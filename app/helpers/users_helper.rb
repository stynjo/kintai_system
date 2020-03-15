# frozen_string_literal: true

module UsersHelper
  DAYS_OF_THE_WEEK = %w[日 月 火 水 木 金 土].freeze

  # 勤怠基本情報を指定のフォーマットで返します。
  def format_basic_info(time)
    format('%<hour>.2f', hour: ((time.hour * 60) + time.min) / 60.0)
  end

  def colon
    p ':'
  end

  def approval_result(result)
    if result.overwork_enum == '申請中' || result.overwork_enum == 'なし' || result.overwork_enum.nil?
      User.find_by(id: result.overwork_superior_id).name + 'に残業申請中'
    elsif result.overwork_enum == '承認'
      '残業承認'
    elsif result.overwork_enum == '否認'
      '残業否認'
    end
  end

  def change_at_req_result(result)
    if result.change_at_enum == '申請中' || result.change_at_enum == 'なし' || result.change_at_enum.nil?
      User.find_by(id: result.change_attendance_id).name + 'に勤怠変更申請中'
    elsif result.change_at_enum == '承認'
      '勤怠承認済'
    elsif result.change_at_enum == '否認'
      '勤怠変更申請が否認されました。'
    end
  end

  def day_of_week(week_index)
    DAYS_OF_THE_WEEK[week_index]
  end
end
