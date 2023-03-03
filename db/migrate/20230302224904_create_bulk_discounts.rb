class CreateBulkDiscounts < ActiveRecord::Migration[5.2]
  def change
    create_table :bulk_discounts do |t|
      t.references :merchant, foreign_key: true
      t.string :name
      t.float :percentage_discount
      t.integer :quantity_threshold
    end
  end
end
