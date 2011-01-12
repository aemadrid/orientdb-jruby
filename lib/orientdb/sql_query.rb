module OrientDB

  class SqlQuery

    def inspect
      %{#<OrientDB::SqlQuery:#{name} text="#{text}">}
    end

    alias :to_s :inspect

  end

end
