class CreatePeople < ActiveRecord::Migration
  def change
    create_table :people do |t|
      t.string :reference
      t.string :email
      t.string :home_phone_number
      t.string :mobile_phone_number
      t.string :firstname
      t.string :lastname
      t.string :address

      t.timestamps null: false
    end
  end
end
