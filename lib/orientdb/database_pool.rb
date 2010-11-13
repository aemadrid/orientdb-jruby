module OrientDB

  DatabasePool = com.orientechnologies.orient.core.db.document.ODatabaseDocumentPool

  class DatabasePool

    def initialize(database_url, username, password)
      self.class.global.acquire database_url, username, password
    end

  end

end