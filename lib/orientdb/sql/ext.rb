module OrientDB
  module SQL

    def monkey_patched
      @monkey_patched ||= []
    end

    module_function :monkey_patched

    def monkey_patched?(name)
      monkey_patched.include? name.to_s.downcase.to_sym
    end

    module_function :monkey_patched?

    # Extend strings and/or symbols to create queries easier
    def monkey_patch!(*args)
      args = %w{ symbol string } if args.empty?
      args.each do |arg|
        case arg.to_s.downcase.to_sym
          when :symbol
            if monkey_patched?(:symbol)
              puts "Symbol has already been monkey patched!"
              false
            else
              Symbol.send :include, OrderExtension
              Symbol.send :include, ConditionalExtension
              Symbol.send :include, FieldOperatorExtension
              Symbol.send :include, BundledFunctionExtension
              monkey_patched << :symbol
              true
            end
          when :string
            if monkey_patched?(:string)
              puts "String has already been monkey patched!"
              false
            else
              String.send :include, OrderExtension
              String.send :include, ConditionalExtension
              String.send :include, FieldOperatorExtension
              String.send :include, BundledFunctionExtension
              monkey_patched << :string
              true
            end
        end
      end
    end

    module_function :monkey_patch!

    module OrderExtension
      def asc
        "#{to_s} ASC"
      end

      def desc
        "#{to_s} DESC"
      end
    end

    module ConditionalExtension
      include OrientDB::SQL::UtilsMixin

      def like(value)
        "#{to_s} LIKE #{quote(value)}"
      end

      def eq(value)
        "#{to_s} = #{quote(value)}"
      end

      def lt(value)
        "#{to_s} < #{quote(value)}"
      end

      def lte(value)
        "#{to_s} <= #{quote(value)}"
      end

      def gt(value)
        "#{to_s} > #{quote(value)}"
      end

      def gte(value)
        "#{to_s} >= #{quote(value)}"
      end

      def ne(value)
        "#{to_s} <> #{quote(value)}"
      end

      def is_null
        "#{to_s} IS null"
      end

      def is_not_null
        "#{to_s} IS NOT null"
      end

      def in(*values)
        "#{to_s} IN #{quote(values)}"
      end

      def contains(field, value)
        "#{to_s} contains (#{field} = #{quote(value)})"
      end

      def contains_all(field, value)
        "#{to_s} containsAll (#{field} = #{quote(value)})"
      end

      def contains_key(value)
        "#{to_s} containsKey #{quote(value)}"
      end

      def contains_value(value)
        "#{to_s} containsValue #{quote(value)}"
      end

      def contains_text(value)
        "#{to_s} containsText #{quote(value)}"
      end

      def matches(value)
        "#{to_s} matches #{quote(value)}"
      end
    end

    module FieldOperatorExtension
      include OrientDB::SQL::UtilsMixin

      # Avoided overriding the native method
      def odb_length
        "#{to_s}.length()"
      end

      # Avoided overriding the native method
      def odb_trim
        "#{to_s}.trim()"
      end

      def to_upper_case
        "#{to_s}.toUpperCase()"
      end

      def to_lower_case
        "#{to_s}.toLowerCase()"
      end

      # Avoided overriding the native method
      def odb_left(length)
        "#{to_s}.left(#{quote(length)})"
      end

      # Avoided overriding the native method
      def odb_right(length)
        "#{to_s}.right(#{quote(length)})"
      end

      def sub_string(start, length = nil)
        "#{to_s}.subString(#{quote(start)}#{length ? ", #{quote(length)}" : ''})"
      end

      def char_at(pos)
        "#{to_s}.charAt(#{quote(pos)})"
      end

      def index_of(string, start = nil)
        "#{to_s}.indexOf(#{quote(string)}#{start ? ", #{quote(start)}" : ''})"
      end

      # Avoided overriding the native method
      def odb_format(frmt)
        "#{to_s}.format(#{quote(frmt)})"
      end

      # Avoided overriding the native method
      def odb_size
        "#{to_s}.size()"
      end

      def as_string
        "#{to_s}.asString()"
      end

      def as_integer
        "#{to_s}.asInteger()"
      end

      def as_float
        "#{to_s}.asFloat()"
      end

      def as_date
        "#{to_s}.asDate()"
      end

      def as_date_time
        "#{to_s}.asDateTime()"
      end

      def as_boolean
        "#{to_s}.asBoolean()"
      end
    end

    module BundledFunctionExtension
      include OrientDB::SQL::UtilsMixin

      # Avoided overriding the native method
      def odb_count
        "count(#{to_s})"
      end

      # Avoided overriding the native method
      def odb_min
        "min(#{to_s})"
      end

      # Avoided overriding the native method
      def odb_max
        "max(#{to_s})"
      end

      # Avoided overriding the native method
      def odb_avg
        "avg(#{to_s})"
      end

      # Avoided overriding the native method
      def odb_sum
        "sum(#{to_s})"
      end

      def sysdate
        "sysdate('#{to_s}')"
      end

      # Avoided overriding the native method
      def odb_format_str(*args)
        "format('#{to_s}', #{args.map{|x| quote(x)}.join(', ')})"
      end
    end
  end
end
