class AttendancesController < ApplicationController
  before_action :set_user, only: [:edit_one_month, :update_one_month, :month_request_approval]
  before_action :logged_in_user, only: [:update, :edit_one_month]
  before_action :admin_or_correct_user, only: [:update, :edit_one_month, :update_one_month]
  before_action :set_one_month, only: :edit_one_month

  UPDATE_ERROR_MSG = "勤怠登録に失敗しました。やり直してください。"
  


  def update
    @user = User.find(params[:user_id])
    @attendance = Attendance.find(params[:id])
    # 出勤時間が未登録であることを判定します。
    if @attendance.started_at.nil?
      if @attendance.update_attributes(started_at: Time.current.change(sec: 0))
        flash[:info] = "おはようございます！"
      else
        flash[:danger] = UPDATE_ERROR_MSG
      end
    elsif @attendance.finished_at.nil?
      if @attendance.update_attributes(finished_at: Time.current.change(sec: 0))
        flash[:info] = "お疲れ様でした。"
      else
        flash[:danger] = UPDATE_ERROR_MSG
      end
    end
    redirect_to @user
  end

  def edit_one_month
  end
  
  def update_one_month
    success = true
    
      ActiveRecord::Base.transaction do # トランザクション開始

        attendances_params.each do |id, item|
          if item['started_at'].present? && item['finished_at'].present?
            attendance = Attendance.find(id)
            attendance.update_attributes!(item)
          elsif item['started_at'].empty? && item['finished_at'].empty?
            attendance = Attendance.find(id)
            attendance.update_attributes!(item)
          else
            ActiveRecord::Rollback # トランザクション内のＤＢ操作をロールバック
            success = false
            break
          end
      end
    end

    # トランザクション成功後の処理(ロールバックを含む)
    if success 
      flash[:success] = "1ヶ月分の勤怠情報を更新しました。"
      redirect_to user_url(date: params[:date])
    else
      flash[:danger] = "無効な入力データがあった為、更新をキャンセルしました。"
      redirect_to attendances_edit_one_month_user_url(date: params[:date])
    end
  

    # トランザクション失敗後の処理(更新又はロールバックに失敗=システムエラー)
    rescue => e
      flash[:danger] = e.message
      redirect_to attendances_edit_one_month_user_url(date: params[:date])
  
  end
  
  def edit_overwork_request
    @user = current_user
    @attendance = @user.attendances.find(params[:id])
  end
  
  def update_overwork_request
    @user = current_user
    @attendance = @user.attendances.find(params[:id])
    if @attendance.update_attributes(overwork_params)
      flash[:success] = "残業申請しました。"
      redirect_to @user
    else
      render '@user'
    end  
  end
  
  #各ユーザーからの勤怠認証申請
  def update_month_request
     attendance = Attendance.find_by(user_id: params[:id], worked_on: params[:date])
       if (params[:attendance][:month_superior_id] == "2") || (params[:attendance][:month_superior_id] == "3") 
         attendance.update_attributes(update_month_request_params)
         
         redirect_to user_url
         flash[:success] = "所属長承認を申請しました。"
       else
         redirect_to user_url
         flash[:danger] = "無効な入力データがあった為、更新をキャンセルしました。" 
       end
  end
  
  #勤怠認証申請のおしらせ
  def month_request_approval
    @month_request = Attendance.where(month_superior_id: current_user).where(monthly_enum: "申請中") 
    requested_user = @month_request.pluck(:user_id)
    @users = User.find(requested_user)
  end
  
  #勤怠認証申請の更新
  def update_month_request_approval
    @user = current_user
    monthly_request_approval_params.each do |id, monthly|
      approval = Attendance.find(id)
      approval.update_attributes(monthly)
    end
    flash[:success] = "所属長承認申請を更新しました。"
    redirect_to @user
  end

  private

    # 1ヶ月分の勤怠情報を扱います。
    def attendances_params
      params.require(:user).permit(attendances: [:started_at, :finished_at, :note])[:attendances]
    end
    
    def overwork_params
      params.require(:attendance).permit(:overwork_time, :overwork_note, :overwork_tomorrow, :overwork_superior_id, :overwork_enum)
    end
    
    def update_month_request_params
     params.require(:attendance).permit(:monthly_enum, :month_superior_id)
    end
    
    def monthly_request_approval_params
      params.permit(attendances: [:monthly_enum, :monthly_request_change])[:attendances]
    end
    
    

    # beforeフィルター

    # 管理権限者、または現在ログインしているユーザーを許可します。
    def admin_or_correct_user
      @user = User.find(params[:user_id]) if @user.blank?
      unless current_user?(@user) || current_user.admin?
        flash[:danger] = "編集権限がありません。"
        redirect_to(root_url)
      end  
    end
end