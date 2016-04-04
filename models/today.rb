# Keeps record if new day started
class Today < ActiveRecord::Base
  KEEP_DATA_DAYS = 2
  self.table_name = :today

  class << self
    def expire_old_data
      if new_day?
        NameFinder
          .where("created_at::date < " \
                "(now()::date - '#{KEEP_DATA_DAYS} days'::interval)")
          .delete_all
      end
    end

    private

    def inst
      first || Today.create(today: Gnrd.today)
    end

    def new_day?
      day = inst
      return false if day.today == Gnrd.today
      day.today = Gnrd.today
      day.save!
    end
  end
end
