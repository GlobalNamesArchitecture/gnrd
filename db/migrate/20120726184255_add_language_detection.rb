class AddLanguageDetection < ActiveRecord::Migration
  def change
    add_column :name_finders, :detect_language, :boolean, :default => 1
  end
end
