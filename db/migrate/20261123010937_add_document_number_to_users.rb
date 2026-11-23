class AddDocumentNumberToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :document_number, :string, limit: 11
    add_index :users, :document_number, unique: true
  end
end
