require File.expand_path("../spec_basic_helper", __FILE__)

describe "OrientDB" do

  describe "SQL" do

    describe "Query" do

      it "should do a blank query" do
        @q = OrientDB::SQL::Query.new
        @q.should be_a_kind_of OrientDB::SQL::Query
        @q.to_s.should == 'SELECT FROM'
      end

      describe "quote" do
        it "should quote numeric values correctly" do
          OrientDB::SQL::Query.quote(1).should == "1"
          OrientDB::SQL::Query.quote(1.1).should == "1.1"
          OrientDB::SQL::Query.quote(10_000_000).should == "10000000"
        end

        it "should quote symbols correctly" do
          OrientDB::SQL::Query.quote(:name).should == "name"
        end

        it "should quote strings correctly" do
          OrientDB::SQL::Query.quote("name").should == "'name'"
          OrientDB::SQL::Query.quote("'name'").should == "'name'"
          OrientDB::SQL::Query.quote("O'Brien").should == "'O\\'Brien'"
          OrientDB::SQL::Query.quote("'O\\'Brien'").should == "'O\\'Brien'"
          OrientDB::SQL::Query.quote("O'Brien & O'Malley").should == "'O\\'Brien & O\\'Malley'"
        end

        it "should quote arrays correctly" do
          OrientDB::SQL::Query.quote([:a, 'b', 1]).should == "[a, 'b', 1]"
        end

        it "should quote regular expressions correctly" do
          OrientDB::SQL::Query.quote(/\d{1,3}\.\d{1,3}/).should == "'\\d{1,3}\\.\\d{1,3}'"
        end

        it "should quote record attributes properly" do
          OrientDB::SQL::Query.quote(:@this).should == "@this"
          OrientDB::SQL::Query.quote(:@rid).should == "@rid"
          OrientDB::SQL::Query.quote(:@class).should == "@class"
          OrientDB::SQL::Query.quote(:@version).should == "@version"
          OrientDB::SQL::Query.quote(:@size).should == "@size"
          OrientDB::SQL::Query.quote(:@type).should == "@type"
        end
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

        it "should handle simple arrays" do
          @q.where(['a > 1', 'b < 3', 'c = 5']).to_s.should == 'SELECT FROM WHERE a > 1 AND b < 3 AND c = 5'
        end

        it "should handle concatenation" do
          @q.where(:a => 1).where(:b => 2).to_s.should == 'SELECT FROM WHERE a = 1 AND b = 2'
        end

        it "should handle overriding" do
          @q.where(:a => 1).where!(:b => 2).to_s.should == 'SELECT FROM WHERE b = 2'
        end

        it "should handle simple joined AND conditions" do
          @q.where(:a => 1).and(:b => 2).to_s.should == 'SELECT FROM WHERE a = 1 AND b = 2'
        end

        it "should handle simple joined OR conditions" do
          @q.where(:a => 1).or(:b => 2).to_s.should == 'SELECT FROM WHERE a = 1 OR b = 2'
        end

        it "should handle simple joined AND NOT conditions" do
          @q.where(:a => 1).and_not(:b => 2).to_s.should == 'SELECT FROM WHERE a = 1 AND NOT b = 2'
        end

        it "should handle simple joined OR NOT conditions" do
          @q.where(:a => 1).or_not(:b => 2).to_s.should == 'SELECT FROM WHERE a = 1 OR NOT b = 2'
        end

        it "should handle complex joined AND conditions (1)" do
          @q.where(:a => 1, :b => 2).and(:c => 3).to_s.should == 'SELECT FROM WHERE (a = 1 AND b = 2) AND c = 3'
        end

        it "should handle complex joined AND conditions (2)" do
          @q.where(:a => 1, :b => 2).and(:c => 3, :d => 4).to_s.should == 'SELECT FROM WHERE (a = 1 AND b = 2) AND (c = 3 AND d = 4)'
        end

        it "should handle complex joined OR conditions (1)" do
          @q.where(:a => 1, :b => 2).or(:c => 3).to_s.should == 'SELECT FROM WHERE (a = 1 AND b = 2) OR c = 3'
        end

        it "should handle complex joined OR conditions (2)" do
          @q.where(:a => 1, :b => 2).or(:c => 3, :d => 4).to_s.should == 'SELECT FROM WHERE (a = 1 AND b = 2) OR (c = 3 AND d = 4)'
        end

        it "should handle complex joined AND NOT conditions (1)" do
          @q.where(:a => 1, :b => 2).and_not(:c => 3).to_s.should == 'SELECT FROM WHERE (a = 1 AND b = 2) AND NOT c = 3'
        end

        it "should handle complex joined AND NOT conditions (2)" do
          @q.where(:a => 1, :b => 2).and_not(:c => 3, :d => 4).to_s.should == 'SELECT FROM WHERE (a = 1 AND b = 2) AND NOT (c = 3 AND d = 4)'
        end

        it "should handle complex joined OR NOT conditions (1)" do
          @q.where(:a => 1, :b => 2).or_not(:c => 3).to_s.should == 'SELECT FROM WHERE (a = 1 AND b = 2) OR NOT c = 3'
        end

        it "should handle complex joined OR NOT conditions (2)" do
          @q.where(:a => 1, :b => 2).or_not(:c => 3, :d => 4).to_s.should == 'SELECT FROM WHERE (a = 1 AND b = 2) OR NOT (c = 3 AND d = 4)'
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

      describe "LIMIT" do

        before :each do
          @q = OrientDB::SQL::Query.new
        end

        it "should handle integers" do
          @q.limit(1).to_s.should == 'SELECT FROM LIMIT 1'
        end

        it "should handle strings" do
          @q.limit('1').to_s.should == 'SELECT FROM LIMIT 1'
        end

        it "should handle other types" do
          @q.limit(:'1').to_s.should == 'SELECT FROM LIMIT 1'
        end

        it "should override on concatenation" do
          @q.limit(2).limit(1).to_s.should == 'SELECT FROM LIMIT 1'
        end

        it "should override on bang (alias)" do
          @q.limit!(2).limit!(1).to_s.should == 'SELECT FROM LIMIT 1'
        end
      end

      describe "RANGE" do

        before :each do
          @q = OrientDB::SQL::Query.new
        end

        it "should handle lower only" do
          @q.range('1:1').to_s.should == 'SELECT FROM RANGE 1:1'
        end

        it "should handle lower and higher" do
          @q.range('1:1', '1:5').to_s.should == 'SELECT FROM RANGE 1:1, 1:5'
        end

        it "should override on concatenation" do
          @q.range('2:1', '2:5').range('1:1').to_s.should == 'SELECT FROM RANGE 1:1'
        end

        it "should override on bang (alias)" do
          @q.range!('2:1', '2:5').range!('1:1').to_s.should == 'SELECT FROM RANGE 1:1'
        end
      end

      describe "Monkey Patching" do
        describe Symbol do
          OrientDB::SQL.monkey_patch! Symbol

          describe "Order" do
            it "#asc should work" do
              :name.asc.should == 'name ASC'
            end

            it "#desc should work" do
              :name.desc.should == 'name DESC'
            end
          end

          describe "Conditional" do
            it "#like should work" do
              :name.like("test%").should == "name LIKE 'test%'"
            end

            it "#eq should work" do
              :age.eq(35).should == "age = 35"
            end

            it "#ne should work" do
              :age.ne(35).should == "age <> 35"
            end

            it "#lt should work" do
              :age.lt(35).should == "age < 35"
            end

            it "#lte should work" do
              :age.lte(35).should == "age <= 35"
            end

            it "#gt should work" do
              :age.gt(35).should == "age > 35"
            end

            it "#gte should work" do
              :age.gte(35).should == "age >= 35"
            end

            it "#is_null should work" do
              :name.is_null.should == "name IS null"
            end

            it "#is_not_null should work" do
              :name.is_not_null.should == "name IS NOT null"
            end

            it "#in should work" do
              :age.in(34, 36, 38).should == "age IN [34, 36, 38]"
            end

            it "#contains should work" do
              :name.contains(:name, "tester").should == "name contains (name = 'tester')"
            end

            it "#contains_all should work" do
              :name.contains_all(:name, "tester").should == "name containsAll (name = 'tester')"
            end

            it "#contains_key should work" do
              :name.contains_key("tester").should == "name containsKey 'tester'"
            end

            it "#contains_value should work" do
              :name.contains_value("tester").should == "name containsValue 'tester'"
            end

            it "#contains_text should work" do
              :name.contains_text("tester").should == "name containsText 'tester'"
            end

            it "#matches should work" do
              :name.matches(/(john|mark)/).should == "name matches '(john|mark)'"
            end
          end

          describe "Field Operators" do
            it "#odb_length should work" do
              :name.odb_length.should == "name.length()"
            end

            it "#odb_trim should work" do
              :name.odb_trim.should == "name.trim()"
            end

            it "#to_upper_case should work" do
              :name.to_upper_case.should == "name.toUpperCase()"
            end

            it "#to_lower_case should work" do
              :name.to_lower_case.should == "name.toLowerCase()"
            end

            it "#odb_left should work" do
              :name.odb_left(5).should == "name.left(5)"
            end

            it "#odb_right should work" do
              :name.odb_right(5).should == "name.right(5)"
            end

            it "#sub_string should work" do
              :name.sub_string(3).should == "name.subString(3)"
              :name.sub_string(3, 5).should == "name.subString(3, 5)"
            end

            it "#char_at should work" do
              :name.char_at(3).should == "name.charAt(3)"
            end

            it "#index_of should work" do
              :name.index_of("test").should == "name.indexOf('test')"
              :name.index_of("test", 3).should == "name.indexOf('test', 3)"
            end

            it "#odb_format should work" do
              :name.odb_format('%-20.20s').should == "name.format('%-20.20s')"
            end

            it "#odb_size should work" do
              :name.odb_size.should == "name.size()"
            end

            it "#as_string should work" do
              :name.as_string.should == "name.asString()"
            end

            it "#as_integer should work" do
              :name.as_integer.should == "name.asInteger()"
            end

            it "#as_float should work" do
              :name.as_float.should == "name.asFloat()"
            end

            it "#as_date should work" do
              :name.as_date.should == "name.asDate()"
            end

            it "#as_date_time should work" do
              :name.as_date_time.should == "name.asDateTime()"
            end

            it "#as_boolean should work" do
              :name.as_boolean.should == "name.asBoolean()"
            end
          end

          describe "Bundled Functions" do
            it "#odb_count should work" do
              :name.odb_count.should == "count(name)"
            end

            it "#odb_min should work" do
              :name.odb_min.should == "min(name)"
            end

            it "#odb_max should work" do
              :name.odb_max.should == "max(name)"
            end

            it "#odb_avg should work" do
              :name.odb_avg.should == "avg(name)"
            end

            it "#odb_sum should work" do
              :name.odb_sum.should == "sum(name)"
            end

            it "#sysdate should work" do
              :'yyyy.MM.dd'.sysdate.should == "sysdate('yyyy.MM.dd')"
            end

            it "#odb_format_str should work" do
              :'%d - Mr. %s %s (%s)'.odb_format_str(:id, :name, :surname, :address).should == "format('%d - Mr. %s %s (%s)', id, name, surname, address)"
            end
          end
        end

        describe String do
          OrientDB::SQL.monkey_patch! String

          describe "Order" do
            it "#asc should work" do
              'name'.asc.should == 'name ASC'
            end

            it "#desc should work" do
              'name'.desc.should == 'name DESC'
            end
          end

          describe "Conditional" do
            it "#like should work" do
              'name'.like("test%").should == "name LIKE 'test%'"
            end

            it "#eq should work" do
              'age'.eq(35).should == "age = 35"
            end

            it "#ne should work" do
              'age'.ne(35).should == "age <> 35"
            end

            it "#lt should work" do
              'age'.lt(35).should == "age < 35"
            end

            it "#lte should work" do
              'age'.lte(35).should == "age <= 35"
            end

            it "#gt should work" do
              'age'.gt(35).should == "age > 35"
            end

            it "#gte should work" do
              'age'.gte(35).should == "age >= 35"
            end

            it "#is_null should work" do
              'name'.is_null.should == "name IS null"
            end

            it "#is_not_null should work" do
              'name'.is_not_null.should == "name IS NOT null"
            end

            it "#in should work" do
              'age'.in(34, 36, 38).should == "age IN [34, 36, 38]"
            end

            it "#contains should work" do
              'name'.contains('name', "tester").should == "name contains (name = 'tester')"
            end

            it "#contains_all should work" do
              'name'.contains_all('name', "tester").should == "name containsAll (name = 'tester')"
            end

            it "#contains_key should work" do
              'name'.contains_key("tester").should == "name containsKey 'tester'"
            end

            it "#contains_value should work" do
              'name'.contains_value("tester").should == "name containsValue 'tester'"
            end

            it "#contains_text should work" do
              'name'.contains_text("tester").should == "name containsText 'tester'"
            end

            it "#matches should work" do
              'name'.matches(/(john|mark)/).should == "name matches '(john|mark)'"
            end
          end

          describe "Field Operators" do
            it "#odb_length should work" do
              'name'.odb_length.should == "name.length()"
            end

            it "#odb_trim should work" do
              'name'.odb_trim.should == "name.trim()"
            end

            it "#to_upper_case should work" do
              'name'.to_upper_case.should == "name.toUpperCase()"
            end

            it "#to_lower_case should work" do
              'name'.to_lower_case.should == "name.toLowerCase()"
            end

            it "#odb_left should work" do
              'name'.odb_left(5).should == "name.left(5)"
            end

            it "#odb_right should work" do
              'name'.odb_right(5).should == "name.right(5)"
            end

            it "#sub_string should work" do
              'name'.sub_string(3).should == "name.subString(3)"
              'name'.sub_string(3, 5).should == "name.subString(3, 5)"
            end

            it "#char_at should work" do
              'name'.char_at(3).should == "name.charAt(3)"
            end

            it "#index_of should work" do
              'name'.index_of("test").should == "name.indexOf('test')"
              'name'.index_of("test", 3).should == "name.indexOf('test', 3)"
            end

            it "#odb_format should work" do
              'name'.odb_format('%-20.20s').should == "name.format('%-20.20s')"
            end

            it "#odb_size should work" do
              'name'.odb_size.should == "name.size()"
            end

            it "#as_string should work" do
              'name'.as_string.should == "name.asString()"
            end

            it "#as_integer should work" do
              'name'.as_integer.should == "name.asInteger()"
            end

            it "#as_float should work" do
              'name'.as_float.should == "name.asFloat()"
            end

            it "#as_date should work" do
              'name'.as_date.should == "name.asDate()"
            end

            it "#as_date_time should work" do
              'name'.as_date_time.should == "name.asDateTime()"
            end

            it "#as_boolean should work" do
              'name'.as_boolean.should == "name.asBoolean()"
            end
          end

          describe "Bundled Functions" do
            it "#odb_count should work" do
              'name'.odb_count.should == "count(name)"
            end

            it "#odb_min should work" do
              'name'.odb_min.should == "min(name)"
            end

            it "#odb_max should work" do
              'name'.odb_max.should == "max(name)"
            end

            it "#odb_avg should work" do
              'name'.odb_avg.should == "avg(name)"
            end

            it "#odb_sum should work" do
              'name'.odb_sum.should == "sum(name)"
            end

            it "#sysdate should work" do
              'yyyy.MM.dd'.sysdate.should == "sysdate('yyyy.MM.dd')"
            end

            it "#odb_format_str should work" do
              '%d - Mr. %s %s (%s)'.odb_format_str(:id, :name, :surname, :address).should == "format('%d - Mr. %s %s (%s)', id, name, surname, address)"
            end
          end
        end
      end
    end

  end
end
