require File.expand_path("../spec_basic_helper", __FILE__)

describe "OrientDB" do

  describe "SQL" do

    describe "Query" do

      it "should do a blank query" do
        @q = OrientDB::SQL::Query.new
        @q.should be_a_kind_of OrientDB::SQL::Query
        @q.to_s.should == 'SELECT FROM'
      end

      describe "SELECT" do

        before :each do
          @q = OrientDB::SQL::Query.new
        end

        it "should select simple string columns" do
          @q.select('name').to_s.should == 'SELECT name FROM'
        end

        it "should select with extended dots on __ separated strings" do
          @q.select('name__a').to_s.should == 'SELECT name.a FROM'
        end

        it "should select as alias on ___ separated strings" do
          @q.select('name___a').to_s.should == 'SELECT name AS a FROM'
        end

        it "should select as mixed alias/dots strings" do
          @q.select('name__a___b').to_s.should == 'SELECT name.a AS b FROM'
        end

        it "should select simple symbol columns" do
          @q.select(:name).to_s.should == 'SELECT name FROM'
        end

        it "should select simple integer columns" do
          @q.select(1).to_s.should == 'SELECT 1 FROM'
        end

        it "should select simple hashes" do
          @q.select(:name => :a).to_s.should == 'SELECT name AS a FROM'
        end

        it "should select simple two column arrays as aliases" do
          @q.select(['name', 'a']).to_s.should == 'SELECT name AS a FROM'
        end

        it "should select simple n-column arrays as entries" do
          @q.select(['name', 'age', 'code']).to_s.should == 'SELECT name, age, code FROM'
        end

        it "should select simple multiple parameters as entries" do
          @q.select('name', :age, 1, [:a, :b], :x => :y).to_s.should == 'SELECT name, age, 1, a AS b, x AS y FROM'
        end

        it "should select simple multiple parameters as entries using columns" do
          @q.columns('name', :age, 1, [:a, :b], :x => :y).to_s.should == 'SELECT name, age, 1, a AS b, x AS y FROM'
        end

        it "should handle concatenation" do
          @q.select('name').select(:age).to_s.should == 'SELECT name, age FROM'
        end

        it "should handle overriding" do
          @q.select('name').select!(:age).to_s.should == 'SELECT age FROM'
        end
      end

      describe "FROM" do

        before :each do
          @q = OrientDB::SQL::Query.new
        end

        it "should use a simple string target" do
          @q.from('Developer').to_s.should == 'SELECT FROM Developer'
        end

        it "should use a simple symbol target" do
          @q.from(:Developer).to_s.should == 'SELECT FROM Developer'
        end

        it "should use a simple object target" do
          @q.from(Developer).to_s.should == 'SELECT FROM Developer'
        end

        it "should use multiple simple string targets" do
          @q.from('5:1', '5:3', '5:5').to_s.should == 'SELECT FROM [5:1, 5:3, 5:5]'
        end

        it "should handle concatenation" do
          @q.from('5:1').from('5:3').from('5:5').to_s.should == 'SELECT FROM [5:1, 5:3, 5:5]'
        end

        it "should handle overriding" do
          @q.from('5:1').from!('5:5').to_s.should == 'SELECT FROM 5:5'
        end
      end

      describe "WHERE" do

        before :each do
          @q = OrientDB::SQL::Query.new
        end

        it "should handle simple hashes" do
          @q.where(:a => 1).to_s.should == 'SELECT FROM WHERE a = 1'
        end

        it "should handle simple two column arrays" do
          @q.where([:a, 1]).to_s.should == 'SELECT FROM WHERE a = 1'
        end

        it "should handle simple three column arrays" do
          @q.where([:a, '>=', 1]).to_s.should == 'SELECT FROM WHERE a >= 1'
        end

        it "should handle simple n > 3 column arrays" do
          @q.where(['a > 1', 'b < 3', 'c = 5', 'd <> 7']).to_s.should == 'SELECT FROM WHERE a > 1 AND b < 3 AND c = 5 AND d <> 7'
        end

        it "should handle concatenation" do
          @q.where(:a => 1).where(:b => 2).to_s.should == 'SELECT FROM WHERE a = 1 AND b = 2'
        end

        it "should handle overriding" do
          @q.where(:a => 1).where!(:b => 2).to_s.should == 'SELECT FROM WHERE b = 2'
        end
      end

      describe "ORDER BY" do

        before :each do
          @q = OrientDB::SQL::Query.new
        end

        it "should handle simple hashes" do
          @q.order(:a => :desc).to_s.should == 'SELECT FROM ORDER BY a DESC'
        end

        it "should handle two column arrays" do
          @q.order([:a, :desc]).to_s.should == 'SELECT FROM ORDER BY a DESC'
        end

        it "should handle n column arrays" do
          @q.order([:a, :b, :c]).to_s.should == 'SELECT FROM ORDER BY a, b, c'
        end

        it "should handle simple entries" do
          @q.order(:a, 'b').to_s.should == 'SELECT FROM ORDER BY a, b'
        end

        it "should default to ASC on unrecognized directions" do
          @q.order(:a => :unknown).to_s.should == 'SELECT FROM ORDER BY a ASC'
        end

        it "should handle concatenation" do
          @q.order(:a).order(:b).to_s.should == 'SELECT FROM ORDER BY a, b'
        end

        it "should handle overriding" do
          @q.order(:a).order!(:b).to_s.should == 'SELECT FROM ORDER BY b'
        end
      end
    end

  end
end
