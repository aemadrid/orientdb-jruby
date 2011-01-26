module OrientDB::SQL

  module UtilsMixin

    def select_single_string(arg)
      arg.to_s.split('___').join(' AS ').split('__').join('.')
    end

    def field_name(name)
      name.to_s.split('__').join('.')
    end

    def quote(value)
      case value
        when Numeric, Symbol
          value.to_s
        when String
          quote_string(value)
        when Array
          "[" + value.map { |x| quote(x) }.join(", ") + "]"
        when Regexp
          quote_regexp(value)
        when OrientDB::SQL::LiteralExpression
          value.to_s
        else
          quote value.to_s
      end
    end

    def quote_string(str)
      str = str.dup
      return str if str[0, 1] == "'" && str[-1, 1] == "'"
      last_pos = 0
      while (pos = str.index("'", last_pos))
        str.insert(pos, "\\") if pos > 0 && str[pos - 1, 1] != "\\"
        last_pos = pos + 1
      end
      "'#{str}'"
    end

    def quote_regexp(regexp)
      regexp      = regexp.inspect
      left_index  = regexp.index('/') + 1
      right_index = regexp.rindex('/') - 1
      str         = regexp[left_index..right_index]
      "'#{str}'"
    end

  end

  module ClassClusterParametersMixin

    def oclass(new_oclass)
      @oclass = new_oclass.to_s
      self
    end

    alias :oclass! :oclass

    def cluster(new_cluster)
      @cluster = new_cluster.to_s
      self
    end

    alias :cluster! :cluster

    private

    def target_sql(command)
      command = command.to_s.upcase.gsub('_', ' ')
      if @oclass
        "#{command} #{@oclass} "
      elsif @cluster
        "#{command} cluster:#{@cluster} "
      else
        raise "Missing oclass or cluster"
      end
    end

  end

  module FieldsValuesParametersMixin

    def fields(*args)
      args.each do |arg|
        case arg
          when String, Symbol, Integer
            @fields << field_name(arg)
          when Hash
            arg.each { |k, v| @fields << field_name(k); @values << quote(v) }
          when Array
            arg.each { |x| @fields << field_name(x) }
        end
      end
      self
    end

    def fields!(*args)
      @fields = []
      @values = []
      fields *args
    end

    def values(*args)
      args.each do |arg|
        case arg
          when String, Symbol, Integer
            arg = quote(arg)
            @values << arg
          when Hash
            arg.each { |k, v| @fields << field_name(k); @values << quote(v) }
          when Array
            arg.each { |x| @values << quote(x) }
        end
      end
      self
    end

    def values!(*args)
      @fields = []
      @values = []
      values *args
    end

  end

  module ConditionsParametersMixin
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

    private

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

  end

  class LiteralExpression

    def initialize(value)
      @value = value.to_s
    end

    def to_s
      @value
    end

    include Comparable

    def <=>(other)
      to_s <=> other.to_s
    end

  end

  class ConditionExpression

    attr_reader :conditions

    def initialize(type)
      @type       = type
      @conditions = []
    end

    def type
      @type.to_s.upcase.gsub('_', ' ')
    end

    def add(*conds)
      conds.each do |cond|
        case cond
          when ConditionExpression
            conditions << cond.to_s
          when Hash
            cond.each { |k, v| conditions << "#{k} = #{Query.quote(v)}" }
          when Array
            cond.each { |x| conditions << x.to_s }
          else
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

    include Comparable

    def <=>(other)
      to_s <=> other.to_s
    end
  end

end