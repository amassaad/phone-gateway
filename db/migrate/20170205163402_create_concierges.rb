class CreateConcierges < ActiveRecord::Migration[5.0]
  def change
    create_table :concierges do |t|
      t.integer :counter
      t.integer :bypass

      t.timestamps
    end
  end
end
