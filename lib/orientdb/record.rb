module OrientDB

  class RecordList
    def jruby_value
      map
    end

    def inspect
      "#<OrientDB::RecordList:#{toString}>"
    end

    alias :to_s :inspect
  end

  class RecordMap
    def inspect
      "#<OrientDB::RecordMap:#{toString}>"
    end

    alias :to_s :inspect
  end

  class RecordSet
    def inspect
      "#<OrientDB::RecordSet:#{toString}>"
    end

    alias :to_s :inspect
  end
end