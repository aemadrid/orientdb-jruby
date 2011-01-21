module OrientDB::SQL
  class Query
    include OrientDB::SQL::UtilsMixin
    include OrientDB::SQL::ConditionsParametersMixin
    extend OrientDB::SQL::UtilsMixin

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

    def to_sql_query
      OrientDB::SQLSynchQuery.new to_s
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

    def order_sql
      @order.empty? ? '' : "ORDER BY #{@order.map { |x| x.to_s }.join(', ')} "
    end

    def limit_sql
      @limit.nil? ? '' : "LIMIT #{@limit} "
    end

    def range_sql
      @lower_range.nil? ? '' : "RANGE #{@lower_range}#{@upper_range ? ", #{@upper_range}" : ''} "
    end

    def order_direction_for(value)
      value.to_s.strip.downcase == 'desc' ? 'DESC' : 'ASC'
    end

  end
end