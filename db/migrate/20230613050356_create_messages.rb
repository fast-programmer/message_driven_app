class CreateMessages < ActiveRecord::Migration[6.0]
  def change
    create_table :messages do |t|
      t.text :name, null: false
      t.integer :status, null: false
      t.jsonb :body
      t.timestamps
    end
  end
end
