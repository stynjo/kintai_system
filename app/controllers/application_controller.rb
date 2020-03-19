# frozen_string_literal: true

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include SessionsHelper

  # beforeフィルター

  # paramsハッシュからユーザーを取得します。
  def set_user
    @user = User.find(params[:id])
  end

  # ログイン済みのユーザーか確認します。
  def logged_in_user
    return if logged_in?
    store_location
    flash[:danger] = 'ログインしてください。'
    redirect_to login_url
  end

  # アクセスしたユーザーが現在ログインしているユーザーか確認します。
  def correct_user
    redirect_to(root_url) unless current_user?(@user) || current_user.admin? || current_user.superior?
  end

  # システム管理権限所有かどうか判定します。
  def admin_user
    redirect_to root_url unless current_user.admin?
  end

  # ページ出力前に1ヶ月分のデータの存在を確認・セットします。
  def create_one_month
    set_one_month
    unless @one_month.count == @attendances.count
      ActiveRecord::Base.transaction do
        @one_month.each { |day| @user.attendances.create!(worked_on: day) }
      end
      @attendances = @user.attendances.where(worked_on: @first_day..@last_day).order(:worked_on)
    end
  rescue ActiveRecord::RecordInvalid
    flash[:danger] = 'ページ情報の取得に失敗しました、再アクセスしてください。'
    redirect_to root_url
  end

  def admin_access_ban
    return unless current_user.admin?
    
    flash[:danger] = '管理者はアクセスできません'
    redirect_to root_url
  end
  
  def set_one_month
    if params[:date].nil?
      @first_day = Date.current.beginning_of_month
    else
      params[:date].to_date
    end
    @last_day = @first_day.end_of_month
    @one_month = [*@first_day..@last_day]

    @attendances = @user.attendances.where(worked_on: @first_day..@last_day).order(:worked_on)
  end
end
