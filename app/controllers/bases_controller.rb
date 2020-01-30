class BasesController < ApplicationController
  before_action :admin_user, only: [:destroy, :edit, :update, :index, :new]

  def new
    @base = Base.new
  end
  
  def create
    @base = Base.new(base_params)
    if @base.save
      redirect_to bases_path
    else
      root_path
    end
  end
  
  def index
    @bases = Base.all
  end
  
  def edit 
     @base = Base.find(params[:id])
  end
  
  def destroy
    @base = Base.find(params[:id])
    @base.destroy
    flash[:success] = "#{@base.name}のデータを削除しました。"
    redirect_to bases_path
  end
  
  def update
    @base = Base.find(params[:id])
    if @base.update_attributes(base_params)
      flash[:success] = "拠点情報を更新しました。"
      redirect_to bases_path
    else
      render     
    end
  end
  
  private
  
   def base_params
     params.require(:base).permit(:name, :type, :number)
   end
   
end
