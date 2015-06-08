class ChangeCategoryIdInDocumentsFromStringToInteger < ActiveRecord::Migration
  def change
    change_column :documents, :category_id, 'integer USING CAST(category_id AS integer)'
  end
end
