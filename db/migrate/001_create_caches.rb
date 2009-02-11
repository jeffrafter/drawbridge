class CreateCaches < ActiveRecord::Migration
  def self.up
    create_table(:caches) do |t|
      t.string :number
      t.string :name
      t.text   :data
      t.timestamps
    end

    add_index :caches, [:id, :number, :name]
    add_index :caches, :number
    add_index :caches, :name
  end

  def self.down
    drop_table(:caches)
  end
end
