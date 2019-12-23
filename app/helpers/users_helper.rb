module UsersHelper

  # 勤怠基本情報を指定のフォーマットで返します。  
  def format_basic_info(time)
    format("%.2f", ((time.hour * 60) + time.min) / 60.0)
  end
  
  def  colon
    p ":"
  end
  
  def approval_result(result)
    if result.overwork_enum == '申請中' || result.overwork_enum == 'なし' || result.overwork_enum.nil
      return  User.find_by(id: result.overwork_superior_id).name + "に残業申請中" 
    elsif result.overwork_enum == '承認' 
      return "残業承認" 
    elsif result.overwork_enum == '否認' 
     return "残業否認" 
    end 
  end
  
end