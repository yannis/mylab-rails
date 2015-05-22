class CreateVersions < ActiveRecord::Migration
  def change
    create_table :versions do |t|
      t.string :name, null: false
      t.text :content_md, null: false
      t.text :content_html
      t.integer :document_id, null: false

      t.timestamps null: false
    end

    add_index :versions, :document_id
  end
end
