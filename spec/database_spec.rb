require File.expand_path("../spec_helper", __FILE__)

describe "OrientDB" do

  describe "DocumentDatabase" do

    before :all do
      create_classes
    end

    it "should create a valid simple table" do
      exp_class = "#<OrientDB::OClass:person name=STRING>"
      exp_props = ["#<OrientDB::Propery:name type=string indexed=false mandatory=false not_null=false>"]
      @person_class.to_s.should == exp_class
      @person_class.properties.map { |x| x.to_s }.should == exp_props
    end

    it "should create a valid simple descendant table" do
      exp_class = "#<OrientDB::OClass:customer super=person tab=FLOAT name=STRING>"
      exp_props = [
        "#<OrientDB::Propery:tab type=decimal indexed=false mandatory=false not_null=false>",
        "#<OrientDB::Propery:name type=string indexed=false mandatory=false not_null=false>"
      ]
      @customer_class.to_s.should == exp_class
      @customer_class.properties.map { |x| x.to_s }.should == exp_props
    end

    it "should create a complex table" do
      exp_class = "#<OrientDB::OClass:invoice number=INTEGER(idx) customer=LINK sold_on=DATE total=FLOAT lines=LINKLIST>"
      exp_props = [
        "#<OrientDB::Propery:number type=int indexed=true mandatory=true not_null=false>",
        "#<OrientDB::Propery:customer type=link indexed=false mandatory=false not_null=true>",
        "#<OrientDB::Propery:sold_on type=date indexed=false mandatory=false not_null=false>",
        "#<OrientDB::Propery:total type=decimal indexed=false mandatory=false not_null=false>",
        "#<OrientDB::Propery:lines type=link_list indexed=false mandatory=false not_null=false>"
      ]
      @invoice_class.to_s.should == exp_class
      @invoice_class.properties.map { |x| x.to_s }.should == exp_props
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
