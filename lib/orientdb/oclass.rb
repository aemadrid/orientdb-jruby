module OrientDB

  class OClass

    def type_for(value)
      type = case value
        when SchemaType
          value
        when Symbol
          FIELD_TYPES[value]
        else
          FIELD_TYPES[value.to_s.to_sym]
      end
      raise "Uknown schema type for [#{value}]" unless type
      type
    end

    def add(property_name, type, options = {})
      if type.is_a?(Hash)
        real_type = type.delete(:type)
        return add(property_name, real_type, type)
      end

      property_name = property_name.to_s
      if exists_property(property_name)
        puts "We already have that property name [#{property_name}]"
        return false
      end

      case type
        when Symbol
          prop = create_property property_name, type_for(type)
        when OrientDB::OClass
          prop = create_property property_name, type_for(:link), type
        when Array
          type[0] = type_for(type[0]) if type[0].is_a?(Symbol)
          type[1] = type_for(type[1]) if type[1].is_a?(Symbol)
          prop = create_property property_name, *type
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
      props = properties.map { |x| "#{x.name}=#{x.type.to_s.downcase}#{x.is_indexed? ? '(idx)' : ''}" }.join(' ')
      "#<OrientDB::OClass:" + name +
        (getSuperClass ? ' super=' + getSuperClass.name : '') +
        (props.empty? ? '' : ' ' + props) +
        ">"
    end

    alias :to_s :inspect

    class << self

      def create(db, name, fields = {})
        name        = name.to_s
        add_cluster = fields.delete :add_cluster
        add_cluster = true if add_cluster.nil?

        if db.schema.exists_class? name
          klass = db.get_class name
        else
          if add_cluster && !db.storage.cluster_names.include?(name.downcase)
            cluster = db.storage.add_cluster name.downcase, STORAGE_TYPES[:physical]
            klass   = db.schema.create_class name, cluster
          else
            klass   = db.schema.create_class name
            cluster = db.storage.get_cluster_by_name name.downcase
          end
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
