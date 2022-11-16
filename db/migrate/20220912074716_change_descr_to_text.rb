class ChangeDescrToText < ActiveRecord::Migration[7.0]
  def change
    change_column :tasks, :task_description, :text
    change_column_null :tasks, :task_description, false 
    #Ex:- change_column("admin_users", "email", :string, :limit =>25)
  end
end
