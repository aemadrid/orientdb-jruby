class OrientDB::Document

  include OrientDB::ProxyMixin

  KLASS = com.orientechnologies.orient.core.metadata.schema.OClass

  def initialize(*args)
    if args.first.is_a?(KLASS)
      @proxy_object = args.first
    else
      db, klass_name = args[0], args[1]
      fields = args[2] || {}
      if db && klass_name
        @proxy_object = KLASS.new db, klass_name
        fields.each do |name, value|
          @proxy_object.field name.to_s, value
        end
      else
        @proxy_object = KLASS.new
      end
    end
  end

  class << self

    def create(db, klass_name, fields = {})
      obj = new(db, klass_name, fields)
      obj.save
      obj
    end

  end

end
