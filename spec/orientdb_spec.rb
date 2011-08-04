require 'spec_helper'

describe "OrientDB" do

  it "should create a valid database" do
    DB.should be_a_kind_of OrientDB::DocumentDatabase
    DB.name.should == "test"
  end

end
