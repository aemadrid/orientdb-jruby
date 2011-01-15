class OrientDB::Database

  def auth(username, password)
    open username, password
  end

  alias_method :native_command, :command

  def command(sql_command = nil)
    sql_command = prepare_sql_command sql_command
    exc_cmd     = sql_command.execute
    native_command exc_cmd
  end

  def prepare_sql_command(sql_command)
    return if sql_command.nil?
    case sql_command
      when SQLCommand
        sql_command
      when String
        SQLCommand.new sql_command
      else
        raise "Unknown command type"
    end
  end

  alias_method :native_query, :query

  def query(sql_query = nil)
    sql_query = prepare_sql_query sql_query
    native_query sql_query
  end

  alias :find :query
  alias :all :query

  def first(sql_query = nil)
    sql_query = prepare_sql_query(sql_query).setLimit(1)
    query(sql_query).first
  end

  def prepare_sql_query(sql_query)
    return if sql_query.nil?
    case sql_query
      when OrientDB::SQLSynchQuery
        sql_query
      when String
        OrientDB::SQLSynchQuery.new sql_query
      when Hash
        OrientDB::SQLSynchQuery.new sql_query_from_hash(sql_query)
      else
        raise "Unknown query type"
    end
  end

  def sql_query_from_hash(options = {})
    target = options.delete :oclass
    raise "Missing oclass name" unless target

    columns    = options.delete(:columns) || '*'
    order      = options.delete :order
    order_sql  = order ? " ORDER BY #{order}" : ''
    limit      = options.delete :limit
    limit_sql  = limit ? " LIMIT #{limit}" : ''
    range_low  = options.delete(:range_low) || options.delete(:range)
    range_high = options.delete :range_high
    range_sql  = range_low ? " RANGE #{range_low}#{range_high ? ",#{range_high}" : ''}" : ''
    fields     = options.map { |field, value| "#{field} #{operator_for(value)} #{quote(value)}" }
    where_sql  = fields.size > 0 ? " WHERE #{fields.join(' AND ')}" : ''

    "SELECT #{columns} FROM #{target}" + where_sql + order_sql + limit_sql + range_sql
  end

  def operator_for(value)
    case value
      when Integer, Float, Symbol
        "="
      when String
        value.index('%') ? "LIKE" : "="
      when Array
        "IN"
    end
  end

  def quote(value)
    case value
      when Integer, Float, Symbol
        value.to_s
      when String
        "'#{value}'"
      when Array
        "[" + value.map { |x| quote(x) }.join(", ") + "]"
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


