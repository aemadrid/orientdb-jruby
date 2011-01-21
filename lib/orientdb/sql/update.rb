module OrientDB::SQL
  class Update

    include OrientDB::SQL::UtilsMixin
    include OrientDB::SQL::ClassClusterParametersMixin
    include OrientDB::SQL::FieldsValuesParametersMixin
    include OrientDB::SQL::ConditionsParametersMixin

    def initialize
      @oclass     = nil
      @cluster    = nil
      @action     = "SET"
      @fields     = []
      @values     = []
      @conditions = []
    end

    def action(new_action)
      @action = new_action.to_s.upcase
      self
    end

    alias :action! :action

    def to_s
      (target_sql(:update) + fields_sql + conditions_sql).strip
    end

    def to_sql_command
      OrientDB::SQLCommand.new to_s
    end

    private

    def fields_sql
      raise "Missing fields" if @fields.empty?
      str = "#{@action} "
      if @action == "REMOVE" && @values.empty?
        str += @fields.join(', ')
      else
        raise "Missing values" if @values.empty?
        raise "Unbalanced fields & values" unless @values.size == @fields.size
        ary = []
        @fields.each_with_index do |field, idx|
          ary << "#{field} = #{@values[idx]}"
        end
        str += ary.join(", ")
      end
      str + ' '
    end

    def values_sql
      "(#{@values.join(', ')})"
    end

  end
end