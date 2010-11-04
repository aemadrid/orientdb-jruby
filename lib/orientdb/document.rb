class OrientDB::Document

  include OrientDB::ProxyMixin

  KLASS = com.orientechnologies.orient.core.record.impl.ODocument

  def initialize(*args)
    if args.first.is_a?(KLASS)
      @proxy_object = args.first
    else
      db, klass_name = args[0], args[1]
      fields = args[2] || {}
      if db && klass_name
        @proxy_object = KLASS.new db.proxy_object, klass_name
        fields.each do |name, value|
          self[name] = value
        end
      else
        @proxy_object = KLASS.new
      end
    end
  end

  def values
    proxy_object.fieldNames.map{|field_name| [field_name, self[field_name]] }
  end

  def db
    proxy_object.getDatabase
  end

#  def save
#    db.save proxy_object
#  end

  def [](field_name)
    value = proxy_object.field field_name.to_s
    value = OrientDB::Document.new(value) if value.is_a?(KLASS)
    value
  end

  def []=(field_name, value)
    value = value.proxy_object if value.respond_to?(:proxy_object)
#    value = value.to_java if value.respond_to?(:to_java)
    proxy_object.field field_name.to_s, value
  end

  def method_missing(method_name, *args, &blk)
    return self[method_name] if proxy_object.containsField(method_name.to_s)
    match = method_name.to_s.match(/(.*?)([?=!]?)$/)
    case match[2]
      when "="
        self[match[1]] =  args.first
      when "?"
        !!self[match[1]]
      else
        super
    end
  end

  def inspect
    props = values.map{|k,v| "#{k}:#{v}" }.join(' ')
    %{#<OrientDB::Document:#{proxy_object.getClassName}#{props.empty? ? '' : ' ' + props}>}
  end

  alias :to_s :inspect

  class << self

    def create(db, klass_name, fields = {})
      obj = new(db, klass_name, fields)
      obj.save
      obj
    end

  end

end
