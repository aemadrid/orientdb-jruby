require File.expand_path("../spec_helper", __FILE__)

describe "OrientDB" do

  describe "Document" do

    before :all do
      create_classes

      @h_fields = {:sku => 'H509', :title => "Hammer", :price => 3.25}
      @hammer   = OrientDB::Document.create DB, @product_class.name, @h_fields

      @n_fields = {:sku => 'N034', :title => "Nail", :price => 0.25}
      @nail     = OrientDB::Document.create DB, @product_class.name, @n_fields

      @line1    = OrientDB::Document.create DB, @line_class.name,
                                            :product  => @hammer,
                                            :quantity => 1,
                                            :price    => @hammer.price
      @line2    = OrientDB::Document.create DB, @line_class.name,
                                            :product  => @nail,
                                            :quantity => 10,
                                            :price    => @nail.price
      @lines    = [@line1, @line2]
      @total    = @lines.inject(0.0) { |a, x| a + x.price * x.quantity }

      @customer = OrientDB::Document.create DB, @customer_class.name,
                                            :name => "Mark Dumber",
                                            :tab  => 500.00

      @invoice  = OrientDB::Document.create DB, @invoice_class.name,
                                            :number   => 10001,
                                            :customer => @customer,
                                            :total    => @total.to_s,
                                            :sold_on  => Date.civil(2011, 1, 1).proxy_object,
                                            :lines    => @lines
    end

    it "should instantiate new documents" do
      @screw = OrientDB::Document.new DB, @product_class.name, :sku => "S365", :price => 0.33
      @screw.should be_a_kind_of OrientDB::Document
    end

    it "should create simple documents" do
      @hammer.should be_a_kind_of OrientDB::Document
      @hammer.to_s.should == "#<OrientDB::Document:product:8:0 title:\"Hammer\" price:3.25 sku:\"H509\">"
      @h_fields.each { |k, v| @hammer[k].should == v }

      @nail.should be_a_kind_of OrientDB::Document
      @nail.to_s.should == "#<OrientDB::Document:product:8:1 title:\"Nail\" price:0.25 sku:\"N034\">"
      @n_fields.each { |k, v| @nail.send(k).should == v }
    end

    it "should create embedded documents" do
      @line1.should be_a_kind_of OrientDB::Document
      @line1.to_s.should == "#<OrientDB::Document:invoice_line:9:0 product:#<OrientDB::Document:product:8:0 title:\"Hammer\" price:3.25 sku:\"H509\"> price:3.25 quantity:1>"
      @line1.product.should == @hammer
      @line1.price.should == @hammer.price

      @line2.should be_a_kind_of OrientDB::Document
      @line2.to_s.should == "#<OrientDB::Document:invoice_line:9:1 product:#<OrientDB::Document:product:8:1 title:\"Nail\" price:0.25 sku:\"N034\"> price:0.25 quantity:10>"
      @line2.product.should == @nail
      @line2.price.should == @nail.price
    end

    it "should create complex, embedded documents" do
      @invoice.should be_a_kind_of OrientDB::Document
#      @invoice.to_s.should == "#<OrientDB::Document:invoice_line:8:0 product:#<OrientDB::Document:product:7:0 title:Hammer price:5.5 sku:H509> price:5.5 quantity:1>"
      @invoice.customer.should == @customer
      @invoice.total = @total
      @invoice.lines.should == [@line1, @line2]
    end
  end

end
