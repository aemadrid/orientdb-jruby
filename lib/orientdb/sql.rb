require 'orientdb/sql_ext'

module OrientDB
  module SQL

    class ConditionExpression

      attr_reader :conditions

      def initialize(type)
        @type       = type
        @conditions = []
        add(conds) if conds
      end

      def type
        @type.to_s.upcase.gsub('_', ' ')
      end

      def add(*conds)
        puts "add : #{conds.inspect}"
        conds.each do |cond|
          case cond
            when ConditionExpression
              puts "ConditionExpression : #{cond.class.name} : #{cond.inspect}"
              conditions << cond.to_s
            when Hash
              puts "Hash : #{cond.class.name} : #{cond.inspect}"
              cond.each { |k, v| conditions << "#{k} = #{Query.quote(v)}" }
            when Array
              puts "Array : #{cond.class.name} : #{cond.inspect}"
              cond.each { |x| conditions << x.to_s }
            else
              puts "else : #{cond.class.name} : #{cond.inspect}"
              conditions << cond.to_s
          end
        end
      end

      def clear
        @conditions = []
      end

      def conditions_str
        conditions.join(' AND ')
      end

      def parens_conditions_str
        conditions.size > 1 ? "(#{conditions_str})" : conditions_str
      end

      def to_s
        "#{type} #{parens_conditions_str} "
      end
    end

    class Query

      attr_reader :projections, :targets, :conditions, :order, :limit, :lower_range, :upper_range, :plan

      def initialize
        @projections = []
        @targets     = []
        @conditions  = []
        @order       = []
        @limit       = nil
        @lower_range = nil
        @upper_range = nil
        @plan        = nil
      end

      def select(*args)
        args.each do |arg|
          case arg
            when String, Symbol, Integer
              arg = select_single_string(arg)
              @projections << arg
            when Hash
              arg.each { |k, v| @projections << "#{k} AS #{v}" }
            when Array
              if arg.size == 2
                @projections << "#{arg.first} AS #{arg.last}"
              else
                arg.each { |x| @projections << select_single_string(x) }
              end
          end
        end
        self
      end

      alias :columns :select

      def select!(*args)
        @projections = []
        select *args
      end

      def from(*args)
        args.each { |x| @targets << x.to_s }
        self
      end

      def from!(*args)
        @targets = []
        from *args
      end

      def where(*args)
        @conditions << ConditionExpression.new(:and) if @conditions.empty?
        @conditions.last.add *args
        self
      end

      def where!(*args)
        @conditions = []
        where *args
      end

      def and(*args)
        @conditions << ConditionExpression.new(:and)
        @conditions.last.add *args
        self
      end

      def or(*args)
        @conditions << ConditionExpression.new(:or)
        @conditions.last.add *args
        self
      end

      def and_not(*args)
        @conditions << ConditionExpression.new(:and_not)
        @conditions.last.add *args
        self
      end

      def or_not(*args)
        @conditions << ConditionExpression.new(:or_not)
        @conditions.last.add *args
        self
      end

      def order(*args)
        args.each do |arg|
          case arg
            when Hash
              arg.each { |k, v| @order << "#{k} #{order_direction_for(v)}" }
            when Array
              case arg.size
                when 2
                  @order << "#{arg[0]} #{order_direction_for(arg[1])}"
                else
                  arg.each { |x| @order << x.to_s }
              end
            else
              @order << arg.to_s
          end
        end
        self
      end

      def order!(*args)
        @order = []
        order *args
      end

      def limit(max_records)
        @limit = max_records.to_s.to_i
        self
      end

      alias :limit! :limit

      def range(lower_rid, upper_rid = nil)
        @lower_range = lower_rid.to_s
        @upper_range = upper_rid ? upper_rid.to_s : nil
        self
      end

      alias :range! :range

      def to_s
        (select_sql + target_sql + conditions_sql + order_sql + limit_sql + range_sql).strip
      end

      def to_sql_synch_query
        OrientDB::SQLSynchQuery.new to_s
      end

      def self.quote(value)
        case value
          when Numeric, Symbol
            value.to_s
          when String
            quote_string(value)
          when Array
            "[" + value.map { |x| quote(x) }.join(", ") + "]"
          when Regexp
            quote_regexp(value)
        end
      end

      def self.quote_string(str)
        str = str.dup
        return str if str[0, 1] == "'" && str[-1, 1] == "'"
        last_pos = 0
        while (pos = str.index("'", last_pos))
          str.insert(pos, "\\") if pos > 0 && str[pos - 1, 1] != "\\"
          last_pos = pos + 1
        end
        "'#{str}'"
      end

      def self.quote_regexp(regexp)
        regexp      = regexp.inspect
        left_index  = regexp.index('/') + 1
        right_index = regexp.rindex('/') - 1
        str         = regexp[left_index..right_index]
        "'#{str}'"
      end

      def quote(value)
        self.class.quote value
      end

      private

      def select_sql
        str = @projections.empty? ? '' : @projections.map { |x| x.to_s }.join(', ') + ' '
        "SELECT #{str}"
      end

      def target_sql
        case @targets.size
          when 0
            "FROM "
          when 1
            "FROM #{@targets.first} "
          else
            "FROM [#{@targets.map { |x| x.to_s }.join(", ")}] "
        end
      end

      def conditions_sql
        case @conditions.size
          when 0
            ''
          when 1
            "WHERE #{@conditions.first.conditions_str} "
          else
            "WHERE #{@conditions.first.parens_conditions_str} #{@conditions[1..-1].map { |x| x.to_s }.join('')}"
        end
      end

      def order_sql
        @order.empty? ? '' : "ORDER BY #{@order.map { |x| x.to_s }.join(', ')} "
      end

      def limit_sql
        @limit.nil? ? '' : "LIMIT #{@limit} "
      end

      def range_sql
        @lower_range.nil? ? '' : "RANGE #{@lower_range}#{@upper_range ? ", #{@upper_range}" : ''} "
      end

      def select_single_string(arg)
        arg.to_s.split('___').join(' AS ').split('__').join('.')
      end

      def order_direction_for(value)
        value.to_s.strip.downcase == 'desc' ? 'DESC' : 'ASC'
      end

    end
  end
end