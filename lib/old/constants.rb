module OrientDB

  #IndexType              = com.orientechnologies.orient.core.metadata.schema::OProperty::INDEX_TYPE

  #INDEX_TYPES            = %w{ FULLTEXT NOTUNIQUE UNIQUE }.inject({}) { |h, s| h[s.downcase.to_sym] = IndexType.const_get s; h }

end