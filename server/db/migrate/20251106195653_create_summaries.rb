class CreateSummaries < ActiveRecord::Migration[8.1]
  def change
    create_table :summaries do |t|
      t.text :original_post
      t.text :summary
      t.string :status, null: false, default: "pending"
      t.datetime :summarized_at

      t.timestamps
    end
  end
end
