class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users, :force => true do |t|
      t.string :status
      t.string :email
      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end
