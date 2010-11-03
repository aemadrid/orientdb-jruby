class OrientDB::Database

  include OrientDB::Mixins::Proxy

  KLASS = com.orientechnologies.orient.core.db.document.ODatabaseDocumentTx

  def initialize(database_url)
    @proxy_object = KLASS.new database_url
  end

  def auth(username, password)
    proxy_object.open username, password
  end

  def user
    OrientDB::User.from_ouser proxy_object.getUser
  end

  alias :each_in_class  :browseClass
  alias :each_in_custer :browseCluster


  class << self

    def create(database_url)
      new(database_url).create
    end

    def connect(database_url, username, password)
      new(database_url).auth(username, password)
    end

  end

end