require 'active_record'
require 'minitest/autorun'

ActiveRecord::Base.establish_connection :adapter => 'sqlite3', :database => ':memory:'

class Post < ActiveRecord::Base
  has_many :comments, :inverse_of => :post

  connection.create_table table_name, :force => true do |t|
    t.string :name
  end
end

class Comment < ActiveRecord::Base
  belongs_to :post, :inverse_of => :comments

  connection.create_table table_name, :force => true do |t|
    t.integer :post_id
    t.string :name
  end
end

describe 'inverse_of with has_many' do
  before do
    @comment = Comment.create!(:name => 'comment')
    @post = Post.create!(:name => 'post')
    @post.comments = [@comment]
    @post.save!
  end

  it 'comment post name matches when post name changed' do
    @comment.post.name.must_equal 'post'
    @post.name = 'new name'
    @comment.post.name.must_equal 'new name'
  end

  it 'post name matches when comment post name changed' do
    @comment.post.name = 'new name from comment'
    @post.name.must_equal 'new name from comment'
  end

  it 'reloaded post in comment cannot retain inverse of connection' do
    @comment.post.reload
    @comment.post.name = 'new name from comment after reload'
    @post.name.must_equal 'new name from comment after reload'
  end
end
