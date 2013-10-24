module OrientDB

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

    def field?(name)
      contains_field(name.to_s) || (schema_class && schema_class.exists_property?(name.to_s))
    end

    def respond_to?(method_name)
      return true if field?(method_name.to_s)
      match = method_name.to_s.match(/(.*?)([?=!]?)$/)
      return true if match[2] == '='
      return true if match[2] == '?' && field?(match[1])
      super
    end

    def method_missing(method_name, *args, &blk)
      return self[method_name] if field?(method_name)

      match = method_name.to_s.match(/(.*?)([?=!]?)$/)
      case match[2]
        when "="
          self[match[1]] =  args.first
        when "?"
          field(match[1]) ? !!self[match[1]] : super
        else
          super
      end
    end

    def rid
      identity.to_s
    end

    def inspect
      props = values.map { |k, v| "#{k}:#{v.inspect}" }.join(' ')
      %{#<OrientDB::Document:#{class_name}:#{rid}#{props.empty? ? '' : ' ' + props}>}
    end

    alias :to_s :inspect

    class << self

      alias_method :native_new, :new

      def new(db, klass_name, fields = {})
        obj = native_new klass_name.to_s
        fields.each do |name, value|
          obj.field name.to_s, value
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
