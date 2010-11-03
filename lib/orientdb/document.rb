class OrientDB::Document

  include OrientDB::Mixins::Proxy

  KLASS = com.orientechnologies.orient.core.record.impl.ODocument

  def initialize(db, klass_name, fields = {})
    @proxy_object = KLASS.new db, klass_name
    fields.each do |name, value|
      @proxy_object.field name.to_s, value
    end
  end

  class << self

    def create(db, klass_name, fields = {})
      new(db, klass_name, fields).save
    end
  end

end
