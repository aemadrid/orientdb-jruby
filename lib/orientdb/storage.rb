module OrientDB

  class LocalStorage

    def get_cluster(name_or_id)
      case name_or_id
        when Integer
          getClusterById name_or_id
        else
          getClusterByName name_or_id.to_s
      end
    end

    def inspect
      "#<OrientDB::LocalStorage:#{hashCode}>"
    end

    alias :to_s :inspect

  end

  class RemoteStorage

    def get_cluster(name_or_id)
      case name_or_id
        when Integer
          getClusterById name_or_id
        else
          getClusterByName name_or_id.to_s
      end
    end

    def inspect
      "#<OrientDB::RemoteStorage:#{hashCode}>"
    end

    alias :to_s :inspect

  end

  class LocalCluster

    def inspect
      "#<OrientDB::LocalCluster:#{getId} name=#{getName.inspect}>"
    end

    alias :to_s :inspect

  end

end
