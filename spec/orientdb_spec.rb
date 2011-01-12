require File.expand_path("../spec_helper", __FILE__)

describe "OrientDB" do

  it "should create a valid database" do
    DB.should be_a_kind_of OrientDB::Database
    DB.name.should == "test"
  end

end
