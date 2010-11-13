module OrientDB


  OClass        = com.orientechnologies.orient.core.metadata.schema.OClass

#  SchemaType    = com.orientechnologies.orient.core.metadata.schema.OType
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

  STORAGE_TYPES = %w{ LOGICAL MEMORY PHYSICAL }.inject({}) { |h, s| h[s.downcase.to_sym] = ClusterType.const_get s; h }
  INDEX_TYPES   = %w{ FULLTEXT NOT_UNIQUE UNIQUE }.inject({}) { |h, s| h[s.downcase.to_sym] = IndexType.const_get s; h }

  class OClass

    def add(property_name, type)
      property_name = property_name.to_s
      if exists_property(property_name)
        puts "We already have that property name [#{property_name}]"
        return false
      end

      case type
        when Symbol
          create_property property_name, FIELD_TYPES[type]
        when OrientDB::OClass
          create_property property_name, FIELD_TYPES[:link], type
        when Array
          type[0] = FIELD_TYPES[type[0]] if type[0].is_a?(Symbol)
          create_property property_name, *type
        when Hash
          raise "Missing property type for [#{property_name}]" unless type[:type]
          if type[:type].is_a?(OrientDB::OClass)
            prop = create_property property_name, FIELD_TYPES[:link], type[:type]
          else
            prop = create_property property_name, FIELD_TYPES[type[:type]]
          end
          prop.set_min type[:min].to_s unless type[:min].nil?
          prop.set_max type[:max].to_s unless type[:max].nil?
          prop.set_mandatory !!type[:mandatory] unless type[:mandatory].nil?
          prop.set_not_null type[:not_null] unless type[:not_null].nil?
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
      exists_property(property_name) ? get_property(property_name) : nil
    end

    def db
      document.database
    end

    def schema
      db.metadata.schema
    end

    def inspect
      props = properties.map { |x| "#{x.name}:#{x.type.to_s.downcase}" }.join(' ')
      %{#<OrientDB::OClass:#{name}#{props.empty? ? '' : ' ' + props}>}
    end

    alias :to_s :inspect


    class << self

      def create(db, name, fields = {})
        name        = name.to_s
        add_cluster = fields.delete :add_cluster
        add_cluster = true if add_cluster.nil?

        if add_cluster
          cluster = db.storage.add_cluster name.downcase, STORAGE_TYPES[:physical]
          klass   = db.schema.create_class name, cluster
        else
          klass = db.schema.create_class name
        end

        super_klass = fields.delete :super
        super_klass = db.get_class(super_klass.to_s) unless super_klass.is_a?(OrientDB::OClass)
        klass.set_super_class super_klass if super_klass
        db.schema.save

        unless fields.empty?
          fields.each do |property_name, type|
            klass.add property_name, type
          end
          db.schema.save
        end

        klass
      end

    end

  end


end
