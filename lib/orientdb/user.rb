class OrientDB::User

  include OrientDB::Mixins::Proxy

  KLASS = com.orientechnologies.orient.core.metadata.security.OUser

  def initialize
    @proxy_object = KLASS.new
  end

  def self.from_ouser(ouser)
    obj = new
    obj.instance_variable_set "@proxy_object", ouser
  end

end
