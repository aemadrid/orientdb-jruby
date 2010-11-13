module OrientDB

  Database      = com.orientechnologies.orient.core.db.document.ODatabaseDocumentTx

  SQLQuery      = com.orientechnologies.orient.core.sql.query.OSQLSynchQuery

  class Database

    def auth(username, password)
      open username, password
    end

    alias_method :native_query, :query

    def query(sql_query = nil)
      sql_query = prepare_sql_query sql_query
      native_query sql_query
    end

    alias :find :query

    def first(sql_query = nil)
      sql_query = prepare_sql_query sql_query
      query(sql_query).setLimit(1).map { |x| x }.first
    end

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
      columns    = options.delete(:columns) || '*'
      order      = options.delete :order
      order_sql  = order ? " ORDER BY #{order}" : ''
      fields     = options.map do |field, value|
        cmp = '='
        if value.is_a?(String)
          value = "'" + value + "'"
          cmp = 'LIKE' if value.index('%')
        end
        "#{field} #{cmp} #{value}"
      end
      "SELECT #{columns} FROM #{klass_name} WHERE #{fields.join(' AND ')}#{order_sql}"
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

    def get_or_create_class(klass_name)
      get_class(klass_name) || create_class(klass_name)
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


end