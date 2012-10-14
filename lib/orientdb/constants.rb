module OrientDB

  ClusterType            = com.orientechnologies.orient.core.storage.OStorage::CLUSTER_TYPE
  DocumentDatabase       = com.orientechnologies.orient.core.db.document.ODatabaseDocumentTx
  DocumentDatabasePool   = com.orientechnologies.orient.core.db.document.ODatabaseDocumentPool
  DocumentDatabasePooled = com.orientechnologies.orient.core.db.document.ODatabaseDocumentTxPooled
  Document               = com.orientechnologies.orient.core.record.impl.ODocument
  IndexType              = com.orientechnologies.orient.core.metadata.schema.OClass::INDEX_TYPE
  OClassImpl             = com.orientechnologies.orient.core.metadata.schema.OClassImpl
  LocalStorage           = com.orientechnologies.orient.core.storage.impl.local.OStorageLocal
  LocalCluster           = com.orientechnologies.orient.core.storage.impl.local.OClusterLocal
  PropertyImpl           = com.orientechnologies.orient.core.metadata.schema.OPropertyImpl
  RecordList             = com.orientechnologies.orient.core.db.record.ORecordTrackedList
  RecordSet              = com.orientechnologies.orient.core.db.record.ORecordTrackedSet
  RemoteStorage          = com.orientechnologies.orient.client.remote.OStorageRemote
  Schema                 = com.orientechnologies.orient.core.metadata.schema.OSchema
  SchemaProxy            = com.orientechnologies.orient.core.metadata.schema.OSchemaProxy
  SchemaType             = com.orientechnologies.orient.core.metadata.schema.OType
  SQLCommand             = com.orientechnologies.orient.core.sql.OCommandSQL
  SQLSynchQuery          = com.orientechnologies.orient.core.sql.query.OSQLSynchQuery
  User                   = com.orientechnologies.orient.core.metadata.security.OUser

  INDEX_TYPES   = IndexType.constants.inject({ }) { |h, s| h[s.downcase.to_sym] = IndexType.const_get s; h }
  STORAGE_TYPES = ClusterType.constants.inject({ }) { |h, s| h[s.downcase.to_sym] = ClusterType.const_get s; h }
  FIELD_TYPES   = SchemaType.constants.inject({ }) { |h, s| h[s.downcase.to_sym] = SchemaType.const_get s; h }
  {
    :bool          => "BOOLEAN",
    :double        => "BYTE",
    :datetime      => "DATE",
    :decimal       => "FLOAT",
    :embedded_list => "EMBEDDEDLIST",
    :list          => "EMBEDDEDLIST",
    :embedded_map  => "EMBEDDEDMAP",
    :map           => "EMBEDDEDMAP",
    :embedded_set  => "EMBEDDEDSET",
    :set           => "EMBEDDEDSET",
    :int           => "INTEGER",
    :link_list     => "LINKLIST",
    :link_map      => "LINKMAP",
    :link_set      => "LINKSET",
  }.map do |k,v|
    FIELD_TYPES[k] = SchemaType.const_get(v) unless FIELD_TYPES.key?(k)
  end


end