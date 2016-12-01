class CreatePrefilters < ActiveRecord::Migration
  def change
    create_table :prefilters do |t|
      t.string :field
      t.string :comparator
      t.string :value
      t.references :query

      t.timestamps null: false
    end
  end
end
