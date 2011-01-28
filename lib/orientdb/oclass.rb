module OrientDB

  class OClass

    def type_for(value)
      value = value.oclass if value.respond_to?(:oclass)
      type = case value
               when OrientDB::SchemaType, OrientDB::OClass
                 value
               when String
                 if schema.exists_class?(value)
                   schema.get_class(value)
                 else
                   FIELD_TYPES[value.to_sym]
                 end
               when Symbol
                 FIELD_TYPES[value]
               else
                 FIELD_TYPES[value.to_s.to_sym]
             end
      raise "Uknown schema type for [#{value}]" unless type
      type
    end

    def add(property_name, type, options = { })
      property_name = property_name.to_s
      if exists_property(property_name)
        puts "We already have that property name [#{property_name}]"
        return false
      end

      type = type.oclass if type.respond_to?(:oclass)
      case type
        when SchemaType
          prop = create_property property_name, type
        when Symbol
          prop = create_property property_name, type_for(type)
        when OClass
          prop = create_property property_name, type_for(:link), type
        when Array
          type, sub_type = type_for(type.first), type_for(type.last)
          prop = create_property property_name, type, sub_type
        else
          raise "ERROR! Unknown type [ #{property_name} | #{type} : #{type.class.name} ]"
      end

      prop.set_min options[:min].to_s unless options[:min].nil?
      prop.set_max options[:max].to_s unless options[:max].nil?
      prop.set_mandatory !!options[:mandatory] unless options[:mandatory].nil?
      prop.set_not_null options[:not_null] unless options[:not_null].nil?
      unless options[:index].nil?
        index_type = options[:index] == true ? INDEX_TYPES[:notunique] : INDEX_TYPES[options[:index]]
        prop.createIndex index_type
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
      props = properties.map { |x| "#{x.name}=#{x.type.name}#{x.is_indexed? ? '(idx)' : ''}" }.join(' ')
      "#<OrientDB::OClass:" + name +
        (getSuperClass ? ' super=' + getSuperClass.name : '') +
        (props.empty? ? '' : ' ' + props) +
        ">"
    end

    alias :to_s :inspect

    class << self

      def create(db, name, fields = { })
        name        = name.to_s
        add_cluster = fields.delete :add_cluster
        add_cluster = true if add_cluster.nil?
        use_cluster = fields.delete :use_cluster

        if db.schema.exists_class? name
          klass = db.get_class name
        else
          if use_cluster
            klass = db.schema.create_class name, use_cluster
          elsif add_cluster && !db.storage.cluster_names.include?(name.downcase)
            cluster = db.storage.add_cluster name.downcase, STORAGE_TYPES[:physical]
            klass   = db.schema.create_class name, cluster
          else
            klass = db.schema.create_class name
          end
        end

        super_klass = fields.delete :super
        super_klass = db.get_class(super_klass.to_s) unless super_klass.is_a?(OrientDB::OClass)
        klass.set_super_class super_klass if super_klass
        db.schema.save

        unless fields.empty?
          fields.each do |property_name, type|
            case type
              when Symbol, Array, OrientDB::OClass
                klass.add property_name, type
              when Hash
                options = type.dup
                type    = options.delete :type
                klass.add property_name, type, options
              else
                raise "Unknown field options [#{type.inspect}]"
            end
          end
          db.schema.save
        end

        klass
      end

    end

  end


end
