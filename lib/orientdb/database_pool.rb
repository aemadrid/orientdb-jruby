class OrientDB::DatabasePool

  include OrientDB::ProxyMixin

  KLASS = com.orientechnologies.orient.core.db.document.ODatabaseDocumentPool

  def initialize(database_url, username, password)
    @proxy_object = KLASS.global.acquire database_url, username, password
  end

  class << self

    def connect(database_url, username, password)
      obj = new database_url, username, password
      obj
    end

  end

end