class OrientDB::Database

  def auth(username, password)
    open username, password
  end

  alias_method :native_command, :command

  def command(sql_command = nil)
    sql_command = prepare_sql_command sql_command
    native_command(sql_command).execute(true)
  end

  def prepare_sql_command(sql_command)
    return if sql_command.nil?
    case sql_command
      when OrientDB::SQLCommand
        sql_command
      when String
        OrientDB::SQLCommand.new sql_command
      else
        raise "Unknown command type"
    end
  end

  alias_method :native_query, :query

  def query(sql_query = nil)
    sql_query = prepare_sql_query sql_query
    native_query sql_query
  end

  def first(sql_query = nil)
    sql_query = prepare_sql_query(sql_query).setLimit(1)
    query(sql_query).first
  end

  def prepare_sql_query(sql_query)
    return if sql_query.nil?
    case sql_query
      when OrientDB::SQLSynchQuery
        sql_query
      when OrientDB::SQL::Query
        sql_query.to_sql_synch_query
      when String
        OrientDB::SQLSynchQuery.new(sql_query)
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
    OrientDB::OClass.create self, klass_name.to_s, fields
  end

  def get_or_create_class(klass_name, fields = {})
    get_class(klass_name) || create_class(klass_name, fields)
  end

  def drop_class(klass_name)
    schema.remove_class(klass_name) if schema.exists_class(klass_name)
  end

  def recreate_class(klass_name, fields = {})
    command "DELETE FROM #{klass_name}"
    drop_class klass_name
    create_class klass_name, fields
  end

  alias :each_in_class :browseClass

  def all_in_class(klass_name)
    browse_class(klass_name.to_s).map
  end

  alias :each_in_cluster :browseCluster

  def all_in_cluster(cluster_name)
    browse_cluster(cluster_name.to_s).map
  end

  class << self

    def create(database_url)
      obj = new(database_url)
      obj.create
      obj
    end

    def connect(database_url, username, password)
      obj = new(database_url)
      obj.auth(username, password)
      obj
    end

  end
end


