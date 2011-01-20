$LOAD_PATH.unshift(File.dirname(__FILE__))

unless defined?(SPEC_HELPER_LOADED)

  require 'spec_basic_helper'

  puts "ENV : #{ENV.keys.sort.join(" : ")}"
  puts "ENV : #{ENV.inspect}"

  TEST_URL      = ENV["ORIENTDB_TEST_URL"]
  TEST_USERNAME = ENV["ORIENTDB_TEST_USERNAME"]
  TEST_PASSWORD = ENV["ORIENTDB_TEST_PASSWORD"]

  if TEST_URL && TEST_USERNAME && TEST_PASSWORD
    puts ">> TEST_DB URL : #{TEST_URL} : #{TEST_USERNAME} : #{TEST_PASSWORD}"
    DB = OrientDB::Database.new(TEST_URL).open(TEST_USERNAME, TEST_PASSWORD)
  else
    TEST_DB_PATH = "#{TEMP_DIR}/databases/db_#{rand(999) + 1}"
    FileUtils.remove_dir "#{TEMP_DIR}/databases/"
    FileUtils.mkdir_p TEST_DB_PATH
    puts ">> TEST_DB PATH : #{TEST_DB_PATH}"
    DB = OrientDB::Database.new("local:#{TEST_DB_PATH}/test").create
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

  SPEC_HELPER_LOADED = true
end