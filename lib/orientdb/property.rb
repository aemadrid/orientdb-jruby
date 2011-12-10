module OrientDB
  class PropertyImpl

    def type_short
      @type_short ||= OrientDB::FIELD_TYPES.select { |k, v| v.name == getType.name }.first.first
    end

    def linked_type_short
      @linked_type_short ||= getLinkedType && OrientDB::FIELD_TYPES.select { |k, v| v.name == getLinkedType.name }.first.first
    end

    def info
      {
        :name         => name,
        :type         => type_short,
        :index        => indexed? ? getIndex.name : nil,
        :min          => min,
        :max          => max,
        :mandatory    => is_mandatory?,
        :not_null     => is_not_null?,
        :linked_type  => linked_type_short,
        :linked_class => linked_type_short ? getLinkedClass.name : nil,
      }
    end

    def inspect
      "#<OrientDB::Propery:#{name} type=#{type_short} " +
        "#{linked_type_short ? "linked_type=#{linked_type_short} linked_class=#{getLinkedClass.name}" : ''}" +
        "indexed=#{is_indexed?} mandatory=#{is_mandatory?} not_null=#{is_not_null}" +
        "#{min ? " min=#{min}" : ''}#{max ? " max=#{max}" : ''}" +
        ">"
    end

    alias :to_s :inspect

  end
end
