class OrientDB::DatabasePool

  include OrientDB::Mixins::Proxy

  KLASS = com.orientechnologies.orient.core.db.document.ODatabaseDocumentPool

  def initialize(database_url, username, password)
    @proxy_object = KLASS.global.acquire database_url, username, password
  end

  class << self

    def connect(database_url, username, password)
      new database_url, username, password
    end

  end

end