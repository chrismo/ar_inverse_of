require 'active_record'
require 'minitest/autorun'

ActiveRecord::Base.establish_connection :adapter => 'sqlite3', :database => ':memory:'

class Parent < ActiveRecord::Base
  has_many :children, :inverse_of => :parent

  connection.create_table table_name, :force => true do |t|
    t.string :name
  end
end

class Child < ActiveRecord::Base
  belongs_to :parent, :inverse_of => :children

  connection.create_table table_name, :force => true do |t|
    t.integer :parent_id
    t.string :name
  end
end

describe 'inverse_of with has_many' do
  before(:all) do
    @child = Child.create!(:name => 'child')
    @parent = Parent.create!(:name => 'parent')
    @parent.children = [@child]
    @parent.save!
  end

  it 'child parent name matches when parent name changed' do
    @child.parent.name.must_equal 'parent'
    @parent.name = 'new name'
    @child.parent.name.must_equal 'new name'
  end

  it 'parent name matches when child parent name changed' do
    @child.parent.name = 'new name from child'
    @parent.name.must_equal 'new name from child'
  end

  it 'reloaded parent in child cannot retain inverse of connection' do
    @child.parent.reload
    @child.parent.name = 'new name from child after reload'
    @parent.name.must_equal 'new name from child after reload'
  end
end
