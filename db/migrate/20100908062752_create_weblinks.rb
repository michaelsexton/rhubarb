class CreateWeblinks < ActiveRecord::Migration
  def self.up
    create_table :weblinks do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :weblinks
  end
end
