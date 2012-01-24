module OrientDB
  module DocumentDatabaseMixin

    def run_command(sql_command = nil)
      sql_command = prepare_sql_command sql_command
      command(sql_command).execute(true)
    end

    alias :cmd :run_command

    def prepare_sql_command(command)
      return if command.nil?
      return command.to_sql_command if command.respond_to?(:to_sql_command)
      case command
        when OrientDB::SQLCommand
          command
        when String
          OrientDB::SQLCommand.new command
        else
          raise "Unknown command type"
      end
    end

    def all(sql_query = nil)
      sql_query = prepare_sql_query sql_query
      query sql_query
    end

    def first(sql_query = nil)
      sql_query = prepare_sql_query(sql_query).setLimit(1)
      query(sql_query).first
    end

    def find_by_rid(rid)
      first "SELECT FROM #{rid}"
    end

    def find_by_rids(*rids)
      all "SELECT FROM [#{rids.map{|x| x.to_s}.join(', ')}]"
    end

    def prepare_sql_query(query)
      return if query.nil?
      return query.to_sql_query if query.respond_to?(:to_sql_query)
      case query
        when OrientDB::SQLSynchQuery
          query
        when String
          OrientDB::SQLSynchQuery.new(query)
        else
          raise "Unknown query type"
      end
    end

    def schema
      metadata.schema
    end

    def get_class(klass_name)
      schema.get_class klass_name.to_s
    end

    def create_class(klass_name, fields = {})
      OrientDB::OClassImpl.create self, klass_name.to_s, fields
    end

    def get_or_create_class(klass_name, fields = {})
      get_class(klass_name) || create_class(klass_name, fields)
    end

    def migrate_class(klass_name, fields = {})
      klass = get_or_create_class klass_name
      fields.each do |name, options|
        type = options.delete :type
        klass.add name, type, options
      end
    end

    def drop_class(klass_name)
      schema.remove_class(klass_name) if schema.exists_class(klass_name)
    end

    def recreate_class(klass_name, fields = {})
      run_command("DELETE FROM #{klass_name}") rescue nil
      drop_class(klass_name) rescue nil
      create_class klass_name, fields
    end

    def all_in_class(klass_name)
      browse_class(klass_name.to_s).map
    end

    def all_in_cluster(cluster_name)
      browse_cluster(cluster_name.to_s).map
    end

    def quote(value)
      SQL::Query.quote value
    end

  end

  class DocumentDatabase

    include DocumentDatabaseMixin

    def self.create(database_url)
      new(database_url).create
    end

    def self.connect(database_url, username, password)
      new(database_url).open(username, password)
    end

    def self.current_thread_connection
      Thread.current[:orientdb_connection]
    end

    def self.connect_current_thread(database_url, username, password)
      Thread.current[:orientdb_connection] = connect database_url, username, password
    end

    def self.close_current_thread
      Thread.current[:orientdb_connection] && Thread.current[:orientdb_connection].close
    end

    alias :each_in_class :browseClass
    alias :each_in_cluster :browseCluster

  end

  class DocumentDatabasePool

    def self.connect(url, username, password)
      global.acquire(url, username, password)
    end

    def self.current_thread_connection
      Thread.current[:orientdb_connection]
    end

    def self.connect_current_thread(database_url, username, password)
      Thread.current[:orientdb_connection] = connect database_url, username, password
    end

    def self.close_current_thread
      Thread.current[:orientdb_connection] && Thread.current[:orientdb_connection].close
    end

  end

  class DocumentDatabasePooled

    include DocumentDatabaseMixin

    alias :each_in_class :browseClass
    alias :each_in_cluster :browseCluster

  end

end


