# frozen_string_literal: true

class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :email
      t.string :name
      t.string :identity_platform_id, null: false

      t.timestamps

      t.index %i[identity_platform_id], name: :UK_user_identity_platform, unique: true
    end
  end
end
