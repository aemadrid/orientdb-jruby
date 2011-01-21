module OrientDB::SQL
  class Delete

    include OrientDB::SQL::UtilsMixin
    include OrientDB::SQL::ClassClusterParametersMixin
    include OrientDB::SQL::ConditionsParametersMixin

    def initialize
      @oclass     = nil
      @cluster    = nil
      @conditions = []
    end

    def to_s
      (target_sql(:delete_from) + conditions_sql).strip
    end

    def to_sql_command
      OrientDB::SQLCommand.new to_s
    end

  end
end