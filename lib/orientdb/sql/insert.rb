module OrientDB::SQL
  class Insert

    include OrientDB::SQL::UtilsMixin
    include OrientDB::SQL::ClassClusterParametersMixin
    include OrientDB::SQL::FieldsValuesParametersMixin

    def initialize
      @oclass  = nil
      @cluster = nil
      @fields  = []
      @values  = []
    end

    def to_s
      (target_sql(:insert_into) + fields_sql + values_sql).strip
    end

    def to_sql_command
      OrientDB::SQLCommand.new to_s
    end

    private

    def fields_sql
      raise "Missing fields" if @fields.empty?
      "(#{@fields.join(', ')}) "
    end

    def values_sql
      raise "Missing values" if @values.empty?
      raise "Unbalanced fields & values" unless @values.size == @fields.size
      "VALUES (#{@values.join(', ')}) "
    end

  end
end