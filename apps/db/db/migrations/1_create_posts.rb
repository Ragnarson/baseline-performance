class CreatePosts < Sequel::Migration
  def up
    create_table :posts do
      primary_key :id
      String :title, size: 32
      text :body
      DateTime :created_at
    end
  end

  def down
    drop_table :posts
  end
end
