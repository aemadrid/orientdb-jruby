require File.expand_path("../spec_helper", __FILE__)

describe "OrientDB" do

  describe "DocumentDatabase" do

    before :all do
      create_classes
    end

    it "should create a valid simple table" do
      exp_class = "#<OrientDB::OClassImpl:person name=STRING>"
      exp_props = ["#<OrientDB::Property:name type=string indexed=false mandatory=false not_null=false>"]
      @person_class.to_s.should == exp_class
      @person_class.properties.map { |x| x.to_s }.should == exp_props
    end

    it "should create a valid simple descendant table" do
      exp_class = "#<OrientDB::OClassImpl:customer super=person tab=FLOAT name=STRING>"
      exp_props = [
        "#<OrientDB::Property:tab type=float indexed=false mandatory=false not_null=false>",
        "#<OrientDB::Property:name type=string indexed=false mandatory=false not_null=false>"
      ]
      @customer_class.to_s.should == exp_class
      @customer_class.properties.map { |x| x.to_s }.should == exp_props
    end

    it "should create a complex table" do
      #exp_class = "#<OrientDB::OClassImpl:invoice total=FLOAT sold_on=DATE lines=LINKLIST number=INTEGER(idx) customer=LINK>"
      exp_props = [
        "#<OrientDB::Property:total type=float indexed=false mandatory=false not_null=false>",
        "#<OrientDB::Property:sold_on type=date indexed=false mandatory=false not_null=false>",
        "#<OrientDB::Property:lines type=linklist indexed=false mandatory=false not_null=false>",
        "#<OrientDB::Property:number type=integer indexed=true mandatory=true not_null=false>",
        "#<OrientDB::Property:customer type=link indexed=false mandatory=false not_null=true>"
      ]
      #@invoice_class.to_s.should == exp_class
      #@invoice_class.properties.map { |x| x.to_s }.should == exp_props

      #TODO: test all those things above
      %w(total sold_on lines number customer).each do |property|
        @invoice_class.get_property(property).class.to_s.should == "Java::ComOrientechnologiesOrientCoreMetadataSchema::OPropertyImpl"
      end

      number_prop = @invoice_class.get_property("number")
      number_prop.type.to_s.should == "INTEGER"
      number_prop.indexed.should be_true
      number_prop.mandatory.should be_true
      number_prop.not_null.should be_false
    end

    describe "Query" do

      before :all do
        create_classes

        @oclass    = @employee_class.name
        @e1        = OrientDB::Document.create DB, @oclass, :name => "Mark", :age => 36, :groups => %w{admin sales}
        @e2        = OrientDB::Document.create DB, @oclass, :name => "John", :age => 37, :groups => %w{admin tech}
        @e3        = OrientDB::Document.create DB, @oclass, :name => "Luke", :age => 38, :groups => %w{tech support}
        @e4        = OrientDB::Document.create DB, @oclass, :name => "Matt", :age => 39, :groups => %w{admin office}
        @e5        = OrientDB::Document.create DB, @oclass, :name => "Pete", :age => 40, :groups => %w{vp office}
        @employees = [@e1, @e2, @e3, @e4, @e5]
      end

      it "should prepare valid queries" do
        exp  = "SELECT * FROM #{@oclass}"
        qry1 = DB.prepare_sql_query exp
        qry1.should be_a_kind_of OrientDB::SQLSynchQuery
        qry1.text.should == exp

        qry2 = DB.prepare_sql_query OrientDB::SQL::Query.new.from(@oclass).where(:name => "John")
        qry2.should be_a_kind_of OrientDB::SQLSynchQuery
        qry2.text.should == "SELECT FROM #{@oclass} WHERE name = 'John'"

        qry3 = DB.prepare_sql_query qry2.text
        qry3.should be_a_kind_of OrientDB::SQLSynchQuery
        qry3.text.should == qry2.text

        qry4 = DB.prepare_sql_query qry3
        qry4.should be_a_kind_of OrientDB::SQLSynchQuery
        qry4.text.should == qry2.text
      end

      it "should get all rows for a class" do
        DB.all('SELECT FROM employee').map { |x| x.name }.sort.should == @employees.map { |x| x.name }.sort
      end

      it "should create a valid query and return the right results" do
        qry = OrientDB::SQL::Query.new.from(@oclass).where("'admin' IN groups", 'age > 37')
        DB.first(qry).should == @e4
      end

      it "should find rows by simple field values" do
        DB.first('SELECT * FROM employee WHERE age = 37').should == @e2
      end

      it "should find rows by simple field values" do
        DB.find_by_rid(@e3.rid).rid.should == @e3.rid
      end

      it "should find rows by values in arrays" do
        qry = DB.prepare_sql_query "SELECT * FROM #{@oclass} WHERE 'admin' IN groups"
        DB.all(qry).map { |x| x.name }.sort.should == [@e1, @e2, @e4].map { |x| x.name }.sort
      end

    end

  end

end
