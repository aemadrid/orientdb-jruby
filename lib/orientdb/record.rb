module OrientDB

  class RecordList
    def inspect
      "#<OrientDB::RecordList:#{toString}>"
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