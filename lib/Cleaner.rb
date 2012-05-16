class Cleaner
  @date = Time.now().to_s[0..9]

  def self.run
    today = Time.now().to_s[0..9]
    if @date != today
      ActiveRecord::Base.connection.execute("delete from name_finders where updated_at < DATE_SUB(CURDATE(),INTERVAL 7 DAY)")
      @date = today
    end  
  end

end