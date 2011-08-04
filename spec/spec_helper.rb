require 'spec_basic_helper'

TEST_URL      = ENV["ORIENTDB_TEST_URL"]
TEST_USERNAME = ENV["ORIENTDB_TEST_USERNAME"]
TEST_PASSWORD = ENV["ORIENTDB_TEST_PASSWORD"]
TEST_POOLED   = ENV["ORIENTDB_TEST_POOLED"].to_s[0, 1].downcase == 't'

puts "ENV :: TEST_URL : #{TEST_URL} | TEST_USERNAME : #{TEST_USERNAME} | TEST_PASSWORD : #{TEST_PASSWORD} | TEST_POOLED : #{TEST_POOLED}"

if TEST_URL && TEST_USERNAME && TEST_PASSWORD
  if TEST_POOLED
    puts ">> Testing [#{TEST_URL[0,TEST_URL.index(':')]}] Pooled Database :: TEST_DB URL : #{TEST_URL} : #{TEST_USERNAME} : #{TEST_PASSWORD}"
    DB = OrientDB::DocumentDatabasePool.connect(TEST_URL, TEST_USERNAME, TEST_PASSWORD)
  else
    puts ">> Testing [#{TEST_URL[0,TEST_URL.index(':')]}] Database :: TEST_DB URL : #{TEST_URL} : #{TEST_USERNAME} : #{TEST_PASSWORD}"
    DB = OrientDB::DocumentDatabase.connect(TEST_URL, TEST_USERNAME, TEST_PASSWORD)
  end
else
  TEST_DB_PATH = "#{TEMP_DIR}/databases/db_#{rand(999) + 1}"
  require 'fileutils'
  FileUtils.remove_dir "#{TEMP_DIR}/databases" rescue nil
  FileUtils.mkdir_p TEST_DB_PATH
  puts ">> Testing [local] Database :: TEST_DB PATH : #{TEST_DB_PATH}"
  FileUtils.remove_dir "#{TEMP_DIR}/databases/"
  FileUtils.mkdir_p TEST_DB_PATH
  puts ">> TEST_DB PATH : #{TEST_DB_PATH}"
  DB = OrientDB::DocumentDatabase.new("local:#{TEST_DB_PATH}/test").create
end

module Helpers
  def create_classes
    # People
    @person_class   = DB.recreate_class :person, :name => :string
    # Customers
    @customer_class = DB.recreate_class :customer,
                                        :super => @person_class,
                                        :tab   => :float
    # Employees
    @employee_class = DB.recreate_class :employee,
                                        :super  => @person_class,
                                        :age    => :int,
                                        :groups => [:embedded_list, :string]
    # Products
    @product_class  = DB.recreate_class :product,
                                        :sku   => :string,
                                        :title => :string,
                                        :price => :float
    # Invoice Lines
    @line_class     = DB.recreate_class :invoice_line,
                                        :product  => @product_class,
                                        :quantity => :int,
                                        :price    => :float
    # Invoices
    @invoice_class  = DB.recreate_class :invoice,
                                        :number   => {:type => :int, :mandatory => true, :index => true},
                                        :customer => {:type => @customer_class, :not_null => true},
                                        :sold_on  => :date,
                                        :total    => {:type => :float}, # , :min => java.lang.Float.new('0.01'), :max => java.lang.Float.new('1000.0')
                                        :lines    => [:link_list, @line_class]
  end
end

RSpec.configure do |config|
  include Helpers

  config.color_enabled = true
end
