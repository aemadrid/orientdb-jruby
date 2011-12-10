class OrientDB::RID

  attr_reader :cluster_id, :document_id

  def initialize(rid = '#-1:-1')
    parts = rid.to_s.gsub('#', '').split ":"
    if parts.size == 2
      self.cluster_id = parts.first.to_i
      self.document_id = parts.last.to_i
    else
      raise "Unknown rid [#{rid}]"
    end
  end

  def cluster_id=(value)
    @cluster_id = value.to_s.strip.to_i
  end

  def document_id=(value)
    @document_id = value.to_s.strip.to_i
  end

  def inspect
    "##{cluster_id}:#{@document_id}"
  end

  alias :to_s :inspect

  def unsaved?
    to_s == '#-1:-1'
  end

  def saved?
    cluster_id > 0 && document_id >= 0
  end

  def valid?
    saved? || unsaved?
  end
end

class String
  def valid_orientdb_rid?
    OrientDB::RID.new(self).valid?
  end
end