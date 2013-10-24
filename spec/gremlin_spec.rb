require File.expand_path("../spec_helper", __FILE__)

describe OrientDB do
  describe "Gremlin" do
    before do
      puts "DB = "
      puts DB
      puts DB.inspect
      puts OrientDB::OrientGraph.instance_methods
      begin
        @database = OrientDB::OrientGraph.new(DB)
        puts @database.inspect
        @topper = @database.add_vertex(nil)
        @topper.set_property("name", "Topper")
        @ben = @database.add_vertex(nil)
        @ben.set_property("name", "Ben")
        @topper_knows_ben = @database.add_edge(nil, @topper, @ben, "knows")
        @database.stop_transaction(OrientDB::Conclusion::SUCCESS)
      rescue => e
        puts "hello"
        puts @database.inspect        
        @database.stop_transaction(OrientDB::Conclusion::FAILURE)
        raise e
      end
    end

    describe "GremlinPipeline" do
      subject{OrientDB::Gremlin::GremlinPipeline.new(@database)}
      describe "#v" do

        it "returns on vertices" do
          subject.v.count.should == 2 
        end
      end

      describe "outE" do
        it "returns edges" do
          subject.v.outE("knows").first.should be_a(OrientDB::BLUEPRINTS::impls::orient::OrientEdge)    
        end
      end
    end
  end
end
