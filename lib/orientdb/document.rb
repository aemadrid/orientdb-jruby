module OrientDB

  Document = com.orientechnologies.orient.core.record.impl.ODocument

  class Document

    def values
      field_names.map { |field_name| [field_name, self[field_name]] }
    end

    alias :db :database

    def [](field_name)
      field field_name.to_s
    end

    def []=(field_name, value)
      field field_name.to_s, value
    end

    def method_missing(method_name, *args, &blk)
      return self[method_name] if contains_field(method_name.to_s)
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
      props = values.map { |k, v| "#{k}:#{v}" }.join(' ')
      %{#<OrientDB::Document:#{get_class_name}#{props.empty? ? '' : ' ' + props}>}
    end

    alias :to_s :inspect

    class << self

      alias_method :native_new, :new

      def new(db, klass_name, fields = {})
        obj = native_new db, klass_name
        fields.each do |name, value|
          obj.field name, value
        end
        obj
      end

      def create(db, klass_name, fields = {})
        obj = new db, klass_name, fields
        obj.save
        obj
      end

    end

  end

end
