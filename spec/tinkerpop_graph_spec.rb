require File.expand_path("../spec_helper", __FILE__)

describe "OrientDB" do

  describe "Graph Database" do

    before do
      @database = OrientDB::OrientGraph.new("plocal:#{TEST_DB_PATH}/graph").create
      begin
        @topper = @database.add_vertex(nil)
        @topper.set_property("name", "Topper")
        @ben = @database.add_vertex(nil)
        @ben.set_property("name", "Ben")
        @topper_knows_ben = @database.add_edge(null, @topper, @ben, "knows")
        @database.stop_transaction(Conclusion.SUCCESS)
      rescue
        @database.stop_transaction(Conclusion.FAILURE)
      end
    end

    after do
      if @database
        @database.drop
        @database.close
      end
    end



  end

end
