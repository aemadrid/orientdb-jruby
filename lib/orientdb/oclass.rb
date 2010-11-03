class OrientDB::OClass

  include OrientDB::ProxyMixin

  KLASS         = com.orientechnologies.orient.core.metadata.schema.OClass

  SchemaType    = com.orientechnologies.orient.core.metadata.schema.OType
  ClusterType   = com.orientechnologies.orient.core.storage.OStorage::CLUSTER_TYPE
  IndexType     = com.orientechnologies.orient.core.metadata.schema.OProperty::INDEX_TYPE

  FIELD_TYPES   = {
    :binary        => "BINARY",
    :bool          => "BOOLEAN",
    :boolean       => "BOOLEAN",
    :double        => "BYTE",
    :date          => "DATE",
    :datetime      => "DATE",
    :decimal       => "FLOAT",
    :double        => "DOUBLE",
    :embedded      => "EMBEDDED",
    :embedded_list => "EMBEDDEDLIST",
    :embedded_map  => "EMBEDDEDMAP",
    :embedded_set  => "EMBEDDEDSET",
    :float         => "FLOAT",
    :int           => "INTEGER",
    :integer       => "INTEGER",
    :link          => "LINK",
    :link_list     => "LINKLIST",
    :link_map      => "LINKMAP",
    :link_set      => "LINKSET",
    :long          => "LONG",
    :short         => "SHORT",
    :string        => "STRING",
  }.inject({}) do |h, (k, v)|
    h[k] = SchemaType.const_get v
    h
  end

  STORAGE_TYPES = %w{ LOGICAL MEMORY PHYSICAL }.inject({}) do |h, s|
    h[s.downcase.to_sym] = ClusterType.const_get s
    h
  end

  INDEX_TYPES   = %w{ FULLTEXT NOT_UNIQUE UNIQUE }.inject({}) do |h, s|
    h[s.downcase.to_sym] = IndexType.const_get s
    h
  end

  def initialize(*args)
    if args.first.is_a?(KLASS)
      @proxy_object = args.first
    else
      @proxy_object = KLASS.new
    end
  end

  def add(property_name, type)
    property_name = property_name.to_s
    if proxy_object.existsProperty(property_name)
      puts "We already have that property name [#{property_name}]"
      return false
    end

    case type
      when Symbol
        proxy_object.createProperty property_name, FIELD_TYPES[type]
      when OrientDB::OClass
        proxy_object.createProperty property_name, FIELD_TYPES[:link], type.proxy_object
      when Array
        type[0] = FIELD_TYPES[type[0]] if type[0].is_a?(Symbol)
        proxy_object.createProperty property_name, *type
      when Hash
        type[:type] = FIELD_TYPES[:link] if type[:type].is_a?(Symbol)
        prop    = proxy_object.createProperty property_name, type[:type]
        prop.setMin(type[:min]) unless type[:min].nil?
        prop.setMax(type[:max]) unless type[:max].nil?
        prop.setMandatory(!!type[:mandatory]) unless type[:mandatory].nil?
        prop.setNotNull(type[:not_null]) unless type[:not_null].nil?
        unless type[:index].nil?
          index_type = type[:index] == true ? INDEX_TYPES[:not_unique] : INDEX_TYPES[type[:index]]
          prop.createIndex index_type
        end
      else
        puts "ERROR! Unknown type [ #{property_name} | #{type} : #{type.class.name} ]"
    end
    self
  end

  def [](property_name)
    property_name = property_name.to_s
    proxy_object.exists_property(property_name) ? proxy_object.getProperty(property_name) : nil
  end

  def database
    proxy_object.getDocument.getDatabase
  end
  alias :db :database

  def schema
    database.getMetadata.getSchema
  end

  def inspect
    props = properties.map { |x| "#{x.getName}:#{x.getType.to_s.downcase}" }.join(' ')
    %{#<OrientDB::OClass:#{name}#{props.empty? ? '' : ' ' + props}>}
  end

  alias :to_s :inspect

  class << self

    def create(db, name, fields = {})
      add_cluster = fields.delete :add_cluster
      add_cluster = true if add_cluster.nil?

      if add_cluster
        cluster = db.storage.addCluster name.downcase, STORAGE_TYPES[:physical]
        klass   = db.schema.createClass name, cluster
      else
        klass = db.schema.createClass name
      end

      super_klass = fields.delete :super
      klass.setSuperClass(super_klass) if super_klass
      db.schema.save

      obj         = new klass

      unless fields.empty?
        fields.each do |property_name, type|
          obj.add property_name, type
        end
        db.schema.save
      end

      obj
    end

  end

end
