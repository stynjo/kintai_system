class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy, :update_basic_info, :edit_basic_info]
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy, :edit_basic_info, :update_basic_info]
  before_action :correct_user, only: [:edit, :update,:show]
  before_action :admin_user, only: [:destroy, :edit_basic_info, :update_basic_info, :index]
  before_action :set_one_month, only: :show
  before_action :admin_access_ban, only: :show

  def index
    @users = User.paginate(page: params[:page]).where.not(id: 1)
  end

  def show
    @worked_sum = @attendances.where.not(started_at: nil).where.not(edit_started_at: nil).count
    @over_approval_number = Attendance.where(overwork_superior_id: @user.id).where(overwork_enum: 1).size
    @monthly_request_number = Attendance.where(month_superior_id: @user.id).where(monthly_enum: 1).size
    @change_attendance_number =  Attendance.where(change_attendance_id: @user.id).where(change_at_enum: 1).size
    @at =  @attendances.first
    respond_to do |format|
      format.html
      format.csv do
        send_data render_to_string, filename: "#{@user.name}の勤怠情報.csv", type: :csv
      end
    end
  end
  
  def working_user
    @users = User.all.includes(:attendances)
  end
  
  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      log_in @user
      flash[:success] = '新規作成に成功しました。'
      redirect_to @user
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @user.update_attributes(user_params)
      flash[:success] = "ユーザー情報を更新しました。"
      redirect_to @user
    else
      render :edit      
    end
  end

  def destroy
    @user.destroy
    flash[:success] = "#{@user.name}のデータを削除しました。"
    redirect_to users_url
  end

  def import
    # fileはtmpに自動で一時保存される
    if params[:file] == nil
      flash[:danger] = "インポートするCSVファイルを選択してください。"
      redirect_to users_url
    else
      User.import(params[:file])
      flash[:success] = "CSVインポートによるユーザー登録が完了しました。"
      redirect_to users_url
    end
  end

  def edit_basic_info
  end

  def update_basic_info
    if @user.update_attributes(basic_info_params)
      flash[:success] = "#{@user.name}の基本情報を更新しました。"
    else
      flash[:danger] = "#{@user.name}の更新は失敗しました。<br>" + @user.errors.full_messages.join("<br>")
    end
    redirect_to users_url
  end
  
  def search
    @users = User.search(params[:search])
  end
  

  def edit_overwork_request_approval
    @attendances = Attendance.where(overwork_superior_id: current_user.id).where(overwork_enum: 1)
    user = @attendances.pluck(:user_id)
    @users = User.find(user)
  end 
  
  
  def update_overwork_request_approval
    ActiveRecord::Base.transaction do 
      overwork_request_approval_params.each do |id, approval|
        attendance = Attendance.find(id)
        attendance.update_attributes!(approval)
      end
   end
   flash[:success] = "残業申請を更新しました。（更新は変更欄にチェックの入っている申請にのみ適用されます。）"
   redirect_to user_url
   rescue ActiveRecord::RecordInvalid
   flash[:danger] = "無効な入力データがあった為、更新をキャンセルしました。"
   redirect_to root_url
  end
  
  
  
  private

    def user_params
      params.require(:user).permit(:name, :email, :affiliation, :password, :password_confirmation, :employee_number, :uid)
    end

    def basic_info_params
      params.require(:user).permit(:name, :email, :affiliation, :employee_number, :uid,
                                   :basic_work_time,
                                   :designated_work_start_time, :designated_work_end_time,
                                   :password, :password_confirmation)
    end
    
    
    def overwork_params
      params.require(:attendance).permit(:overwork_time, :overwork_note, :overwork_tomorrow, :overwork_superior_id)
    end
  
    def overwork_request_approval_params
       params.permit(attendances: [:overwork_enum, :overwork_request_change])[:attendances]
    end
    
end