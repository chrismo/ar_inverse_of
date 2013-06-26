require 'active_record'
require 'minitest/autorun'

ActiveRecord::Base.establish_connection :adapter => 'sqlite3', :database => ':memory:'

class Supplier < ActiveRecord::Base
  has_one :account, :inverse_of => :supplier

  connection.create_table table_name, :force => true do |t|
    t.integer :account_id
    t.string :name
  end
end

class Account < ActiveRecord::Base
  belongs_to :supplier, :inverse_of => :account

  connection.create_table table_name, :force => true do |t|
    t.integer :supplier_id
    t.string :name
  end
end

describe 'inverse_of with has_one' do
  before(:all) do
    @supplier = Supplier.create!(:name => 'supplier')
    @account = Account.create!(:name => 'account', :supplier => @supplier)
  end

  it 'supplier account name matches when account name changed' do
    @supplier.account.name.must_equal @account.name
    @account.name = 'new name'
    @supplier.account.name.must_equal 'new name'
  end

  it 'account name matches when supplier account name changed' do
    @supplier.account.name = 'new name from supplier'
    @account.name.must_equal 'new name from supplier'
  end

  it 'reloaded account in supplier cannot retain inverse of connection' do
    @supplier.account.reload
    @supplier.account.name = 'new name from supplier after reload'
    @account.name.must_equal 'new name from supplier after reload'
  end
end
