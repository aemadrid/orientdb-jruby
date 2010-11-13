require File.expand_path("../spec_helper", __FILE__)

describe "OrientDB" do

  before :all do
    @db             = OrientDB::Database.new("local:#{TEST_DB_PATH}/test").create
    @person_class   = @db.create_class :person, :name => :string
    @customer_class = @db.create_class :customer, :super => @person_class
    @product_class  = @db.create_class :product, :sku => :string, :title => :string, :price => :float
    @line_class     = @db.create_class :invoice_line, :product => @product_class, :quantity => :int, :price => :float
    @invoice_class  = @db.create_class :invoice,
                                       :number   => {:type => :int, :mandatory => true, :index => true},
                                       :customer => {:type => @customer_class, :not_null => true},
                                       :sold_on  => :date,
                                       :total    => {:type => :float, :min => 0.01, :max => 100_000.0},
                                       :lines    => :embedded_list
  end

  after :all do
    @db.close
#    puts "Removing files in #{TEMP_DIR}/databases/*"
#    FileUtils.rm_rf "#{TEMP_DIR}/databases/test"
  end

  it "should create a valid database" do
    puts "Creating db #{@db_path}..."
    @db.should be_a_kind_of OrientDB::Database
    @db.name.should == "test"
  end

end
