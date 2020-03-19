# frozen_string_literal: true

class AttendancesController < ApplicationController
  before_action :set_user, only: %i[edit_one_month update_one_month month_request_approval attendance_log]
  before_action :set_attendance, only: %i[update edit_overwork_request update_overwork_request]
  before_action :logged_in_user, only: %i[update edit_one_month]
  before_action :admin_or_correct_user, only: %i[update edit_one_month update_one_month]
  before_action :create_one_month, only: %i[edit_one_month attendance_log]

  UPDATE_ERROR_MSG = '勤怠登録に失敗しました。やり直してください。'

  def update
    # 出勤時間が未登録であることを判定します。
    if upadte_started_at
      flash[:info] = 'おはようございます！'
    elsif upadte_finished_at
      flash[:info] = 'お疲れ様でした。'
    else
      flash[:danger] = UPDATE_ERROR_MSG
    end

    redirect_to @user
  rescue StandardError => e
    flash[:danger] = e.message
    redirect_to @user
  end

  def edit_one_month
    admin_access_ban
  end

  def update_one_month
    success = true

    ActiveRecord::Base.transaction do # トランザクション開始
      attendances_params.each do |id, item|
        if item['edit_started_at'].present? && item['edit_finished_at'].present? && item['change_attendance_id'].present? && item['edit_started_at'] < item['edit_finished_at']
          attendance = Attendance.find(id)
          attendance.update_attributes!(item)
          if attendance.edit_one_month_tomorrow == true
            attendance.edit_finished_at = attendance.edit_finished_at.tomorrow
            attendance.save
          elsif attendance.edit_one_month_tomorrow == false && item['edit_started_at'] > item['edit_finished_at']
            success = false
            break
          end
        elsif item['edit_started_at'].present? && item['edit_finished_at'].present? && item['change_attendance_id'].present? && item['edit_started_at'] > item['edit_finished_at']
          attendance = Attendance.find(id)
          attendance.update_attributes!(item)
          if attendance.edit_one_month_tomorrow == true
            attendance.edit_finished_at = attendance.edit_finished_at.tomorrow
            attendance.save
          elsif attendance.edit_one_month_tomorrow == false
            success = false
            break
          end
        elsif item['edit_started_at'].empty? && item['edit_finished_at'].empty? && item['change_attendance_id'].empty?
          attendance = Attendance.find(id)
          attendance.update_attributes!(item)
        else
          success = false
          raise ActiveRecord::Rollback # トランザクション内のＤＢ操作をロールバック
        end
      end
    end

    # トランザクション成功後の処理(ロールバックを含む)
    if success
      flash[:success] = '1ヶ月分の勤怠情報を更新しました。'
      redirect_to user_url(date: params[:date])
    else
      flash[:danger] = '無効な入力データがあった為、更新をキャンセルしました。'
      redirect_to attendances_edit_one_month_user_url(date: params[:date])
    end

    # トランザクション失敗後の処理(更新又はロールバックに失敗=システムエラー)
  rescue StandardError => e
    flash[:danger] = e.message
    redirect_to attendances_edit_one_month_user_url(date: params[:date])
  end

  def edit_overwork_request
    @user = current_user
  end

  def update_overwork_request
    @user = current_user
    @attendance.redesignated_endtime = @user.designated_work_end_time.change(year: @attendance.worked_on.year,
                                                                             month: @attendance.worked_on.month,
                                                                             day: @attendance.worked_on.day)
    if @attendance.update_attributes(overwork_params)
      @attendance.overwork_time = @attendance.overwork_time.change(year: @attendance.worked_on.year,
                                                                   month: @attendance.worked_on.month,
                                                                   day: @attendance.worked_on.day)
      @attendance.overwork_time = @attendance.overwork_time.tomorrow if @attendance.overwork_tomorrow == true
      @attendance.save
      flash[:success] = '残業申請しました。'
      redirect_to @user
    else
      render '@user'
    end
  end

  # 各ユーザーからの勤怠認証申請
  def update_month_request
    attendance = Attendance.find_by(user_id: params[:id], worked_on: params[:date])
    if (params[:attendance][:month_superior_id] == '2') || (params[:attendance][:month_superior_id] == '3')
      attendance.update_attributes(update_month_request_params)

      redirect_to user_url
      flash[:success] = '所属長承認を申請しました。'
    else
      redirect_to user_url
      flash[:danger] = '無効な入力データがあった為、更新をキャンセルしました。'
    end
  end

  # 勤怠認証申請のおしらせ
  def month_request_approval
    @month_request = Attendance.where(month_superior_id: current_user).where(monthly_enum: '申請中')
    requested_user = @month_request.pluck(:user_id)
    @users = User.find(requested_user)
  end

  # 勤怠認証申請の更新
  def update_month_request_approval
    @user = current_user
    monthly_request_approval_params.each do |id, monthly|
      approval = Attendance.find(id)
      n = approval.id.to_s
      @k = params[:attendances][n][:monthly_request_change]
      if @k == 'true'
        approval.update_attributes!(monthly)
        flash[:success] = '所属長承認申請を更新しました'
      else
        flash[:danger] = '無効な入力データがあった為、更新をキャンセルしました。'
      end
    end
    redirect_to @user
  end

  # 勤怠変更のおしらせ
  def change_attendance_month
    @request_su = Attendance.where(change_attendance_id: current_user).where(change_at_enum: '申請中')
    user = @request_su.pluck(:user_id)
    @users = User.find(user)
  end

  # 勤怠変更更新
  def update_change_attendance_month
    @user = current_user
    change_at_approval_params.each do |id, monthly|
      approval = Attendance.find(id)
      approval.date_of_approvement = DateTime.current
      n = approval.id.to_s
      @k = params[:attendances][n][:change_at_change]
      if @k == 'true'
        approval.started_at = approval.edit_started_at
        approval.finished_at = approval.edit_finished_at
        approval.update_attributes(monthly)
        approval.change_at_change = false
        approval.save
        flash[:success] = '勤怠変更申請を更新しました。'
      else
        flash[:danger] = '無効な入力データがあった為、更新をキャンセルしました。'
      end
    end
    redirect_to @user
  end

  # 勤怠修正ログ
  def attendance_log
    @change_log = @attendances.where(user_id: @user.id).where(change_at_enum: '承認')
    @year = params[:year].to_i
    @month = params[:month].to_i
    select_att = "#{@year}-#{@month}-1"
    if params[:year].present? && params[:month].present?
      @attendances = Attendance.where(worked_on: select_att.in_time_zone.all_month)
      @change_log = @attendances.where(change_at_change: true)
    end
  end

  private

  # 1ヶ月分の勤怠情報を扱います。
  def attendances_params
    params.require(:user).permit(attendances: %i[edit_started_at edit_finished_at note change_attendance_id change_at_enum edit_one_month_tomorrow])[:attendances]
  end

  def overwork_params
    params.require(:attendance).permit(:overwork_time, :overwork_note, :overwork_tomorrow, :overwork_superior_id, :overwork_enum, :redesignated_endtime)
  end

  def update_month_request_params
    params.require(:attendance).permit(:monthly_enum, :month_superior_id)
  end

  def monthly_request_approval_params
    params.permit(attendances: %i[monthly_enum monthly_request_change])[:attendances]
  end

  def change_at_approval_params
    params.permit(attendances: %i[change_at_enum change_at_change])[:attendances]
  end

  # beforeフィルター

  # 管理権限者、または現在ログインしているユーザーを許可します。
  def admin_or_correct_user
    @user = User.find(params[:user_id]) if @user.blank?
    unless current_user?(@user) || current_user.admin?
      flash[:danger] = '編集権限がありません。'
      redirect_to(root_url)
    end
  end

  def set_attendance
    @user = User.find(params[:user_id])
    @attendance = Attendance.find(params[:id])
  end

  def upadte_started_at
    return false unless @attendance.started_at.nil?
    @attendance.update_attributes!(started_at: Time.current.change(sec: 0))
  end

  def upadte_finished_at
    return false unless @attendance.finished_at.nil?
    @attendance.update_attributes!(finished_at: Time.current.change(sec: 0))
  end
end
