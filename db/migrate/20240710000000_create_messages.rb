class CreateMessages < ActiveRecord::Migration[8.0]
  def change
    create_table :messages do |t|
      t.string :role, null: false
      t.text :content
      t.string :status, default: 'pending'
      t.string :conversation_id, null: false
      
      t.timestamps
    end
    
    add_index :messages, :conversation_id
  end
end 