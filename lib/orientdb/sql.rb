module OrientDB::SQL
  class SQLSynchQuery

    def inspect
      %{#<OrientDB::SQLSynchQuery:#{name} text="#{text}">}
    end

    alias :to_s :inspect

  end
end

require 'orientdb/sql/common'
require 'orientdb/sql/ext'
require 'orientdb/sql/query'
require 'orientdb/sql/insert'
require 'orientdb/sql/update'
require 'orientdb/sql/delete'
