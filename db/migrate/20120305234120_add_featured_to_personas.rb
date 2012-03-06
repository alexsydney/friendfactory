class AddFeaturedToPersonas < ActiveRecord::Migration
  def self.up
    add_column :personas, :featured, :boolean rescue nil
    ActiveRecord::Base.transaction do
      User.includes(:personages => :persona).where('`score` > 0').all.each do |user|
        user.personages.each do |personage|
          if persona = personage.persona
            persona.update_attribute(:featured, true)
          end
        end
      end
    end
  end

  def self.down
    remove_column :personas, :featured
  end
end
