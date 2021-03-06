class CreateResourceEvents < ActiveRecord::Migration
  def self.up
    create_table :resource_events, :force => true do |t|
      t.integer     :location_id
      t.datetime    :start_date
      t.datetime    :end_date
      t.text        :body
      t.string      :url

      # t.boolean   :private
      t.integer     :private
      # t.boolean   :rsvp
      t.integer     :rsvp
    end
  end

  def self.down
    drop_table :resource_events rescue nil
  end
end
