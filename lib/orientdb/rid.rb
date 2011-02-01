class OrientDB::RID

  attr_reader :cluster_id, :document_id

  def initialize(rid_str = '-1:-1')
    idx = rid_str.index(':')
    if idx
      self.cluster_id  = rid_str[0, idx]
      self.document_id = rid_str[idx+1..-1]
    else
      raise "Unknown parameters #{args.inspect}"
    end
  end

  def cluster_id=(value)
    @cluster_id = value.to_s.strip.to_i
  end

  def document_id=(value)
    @document_id = value.to_s.strip.to_i
  end

  def inspect
    "#{cluster_id}:#{@document_id}"
  end

  def unsaved?
    to_s == '-1:-1'
  end

  def saved?
    cluster_id > 0 && document_id >= 0
  end

  def valid?
    saved? || unsaved?
  end

  alias :to_s :inspect
end

class String
  def valid_orientdb_rid?
    OrientDB::RID.new(self).valid?
  end
end