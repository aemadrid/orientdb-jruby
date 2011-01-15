require File.expand_path("../spec_basic_helper", __FILE__)

describe "OrientDB" do

  describe "SQL" do

    describe "Query" do

      it "should do a blank query" do
        @q = OrientDB::SQL::Query.new
        @q.should be_a_kind_of OrientDB::SQL::Query
        @q.to_s.should == 'SELECT FROM '
      end

      describe "SELECT" do

        before :each do
          @q = OrientDB::SQL::Query.new
        end

        it "should select simple string columns" do
          @q.select('name').to_s.should == 'SELECT name FROM '
        end

        it "should select with extended dots on __ separated strings" do
          @q.select('name__a').to_s.should == 'SELECT name.a FROM '
        end

        it "should select as alias on ___ separated strings" do
          @q.select('name___a').to_s.should == 'SELECT name AS a FROM '
        end

        it "should select as mixed alias/dots strings" do
          @q.select('name__a___b').to_s.should == 'SELECT name.a AS b FROM '
        end

        it "should select simple symbol columns" do
          @q.select(:name).to_s.should == 'SELECT name FROM '
        end

        it "should select simple integer columns" do
          @q.select(1).to_s.should == 'SELECT 1 FROM '
        end

        it "should select simple hashes" do
          @q.select(:name => :a).to_s.should == 'SELECT name AS a FROM '
        end

        it "should select simple two column arrays as aliases" do
          @q.select(['name', 'a']).to_s.should == 'SELECT name AS a FROM '
        end

        it "should select simple n-column arrays as entries" do
          @q.select(['name', 'age', 'code']).to_s.should == 'SELECT name, age, code FROM '
        end

        it "should select simple multiple parameters as entries" do
          @q.select('name', :age, 1, [:a, :b], :x => :y).to_s.should == 'SELECT name, age, 1, a AS b, x AS y FROM '
        end

        it "should select simple multiple parameters as entries using columns" do
          @q.columns('name', :age, 1, [:a, :b], :x => :y).to_s.should == 'SELECT name, age, 1, a AS b, x AS y FROM '
        end

      end

      describe "FROM" do

        before :each do
          @q = OrientDB::SQL::Query.new
        end

        it "should use a simple string target" do
          @q.from('Developer').to_s.should == 'SELECT FROM Developer '
        end

        it "should use a simple symbol target" do
          @q.from(:Developer).to_s.should == 'SELECT FROM Developer '
        end

        it "should use a simple object target" do
          @q.from(Developer).to_s.should == 'SELECT FROM Developer '
        end

        it "should use multiple simple string targets" do
          @q.from('5:1', '5:3', '5:5').to_s.should == 'SELECT FROM [5:1, 5:3, 5:5] '
        end

      end
    end

  end
end
