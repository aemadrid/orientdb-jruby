$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'orientdb'
require 'rspec'
#require 'rspec/autorun'
require 'fileutils'

unless defined?(SPEC_HELPER_LOADED)

  GEM_ROOT     = File.expand_path(File.join(File.dirname(__FILE__), '..'))
  LIB_ROOT     = GEM_ROOT + '/lib'
  SPEC_ROOT    = GEM_ROOT + '/spec'
  TEMP_DIR     = SPEC_ROOT + '/tmp'

  TEST_DB_PATH = "#{TEMP_DIR}/databases/db_#{rand(999) + 1}"

  puts ">> GEM_ROOT     : #{GEM_ROOT}"
  puts ">> TEST_DB PATH : #{TEST_DB_PATH}"

  $LOAD_PATH.unshift(LIB_ROOT) unless $LOAD_PATH.include?(LIB_ROOT)

  FileUtils.mkdir_p TEST_DB_PATH

  DB = OrientDB::Database.new("local:#{TEST_DB_PATH}/test").create

  module Helpers
    def create_classes
      # People
      @person_class   = DB.create_class :person, :name => :string
      # Customers
      @customer_class = DB.create_class :customer,
                                        :super => @person_class,
                                        :tab   => :float
      # Employees
      @employee_class = DB.create_class :employee,
                                        :super  => @person_class,
                                        :age    => :int,
                                        :groups => [:embedded_list, :string]
      @employee_class.truncate
      @customer_class.truncate
      @person_class.truncate
      # Products
      @product_class = DB.create_class :product,
                                       :sku   => :string,
                                       :title => :string,
                                       :price => :float
      @product_class.truncate
      # Invoice Lines
      @line_class = DB.create_class :invoice_line,
                                    :product  => @product_class,
                                    :quantity => :int,
                                    :price    => :float
      @line_class.truncate
      # Invoices
      @invoice_class = DB.create_class :invoice,
                                       :number   => {:type => :int, :mandatory => true, :index => true},
                                       :customer => {:type => @customer_class, :not_null => true},
                                       :sold_on  => :date,
                                       :total    => {:type => :float}, # , :min => java.lang.Float.new('0.01'), :max => java.lang.Float.new('1000.0')
                                       :lines    => [:link_list, @line_class]
      @invoice_class.truncate
    end
  end

  RSpec.configure do |config|
    include Helpers

    config.color_enabled = true
  end

  SPEC_HELPER_LOADED = true
end