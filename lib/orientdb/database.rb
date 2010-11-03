class OrientDB::Database

  include OrientDB::ProxyMixin

  KLASS         = com.orientechnologies.orient.core.db.document.ODatabaseDocumentTx

  Record        = com.orientechnologies.orient.core.record.ORecord
  Schema        = com.orientechnologies.orient.core.metadata.schema.OSchema
  SQLQuery      = com.orientechnologies.orient.core.sql.query.OSQLSynchQuery

  def initialize(database_url)
    @proxy_object = KLASS.new database_url
  end

  def auth(username, password)
    proxy_object.open username, password
  end

  def user
    User.from_ouser proxy_object.getUser
  end

  def query(sql_query = nil)
    sql_query = prepare_sql_query sql_query
    proxy_object.query(sql_query).map { |x| Document.new x }
  end

  alias :find :query

  def prepare_sql_query(sql_query)
    return if sql_query.nil?
    case sql_query
      when SQLQuery
        sql_query
      when String
        SQLQuery.new sql_query
      when Hash
        SQLQuery.new sql_query_from_hash(sql_query)
      else
        raise "Unknown query type"
    end
  end

  def sql_query_from_hash(options = {})
    klass_name = options.delete :class
    raise "Missing class name" unless klass_name
    columns    = options.delete :columns
    fields     = options.map do |field, value|
      cmp = '='
      if value.is_a?(String)
        value = "'" + value + "'"
        cmp = 'LIKE' if value.index('%')
      end
      "#{field} #{cmp} #{value}"
    end
    "SELECT #{columns} FROM #{klass_name} WHERE #{fields.join(' AND ')}"
  end

  def schema
    proxy_object.getMetadata.getSchema
  end

  def storage
    proxy_object.storage
  end

  def create_class(name, fields = {})
    OrientDB::OClass.create self, name, fields
  end

  def each_in_class(klass_name)
    proxy_object.broseClass(klass_name.to_s).each do |record|
      yield record
    end
  end

  def each_in_custer(cluster_name)
    proxy_object.browseCluster(cluster_name.to_s).each do |record|
      yield record
    end
  end

  def get_class(klass_name)
    klass = schema.get_class klass_name
    klass && OrientDB::OClass.new(klass)
  end

  def get_or_create_class(klass_name)
    get_class(klass_name) || OrientDB::OClass.create(klass_name)
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