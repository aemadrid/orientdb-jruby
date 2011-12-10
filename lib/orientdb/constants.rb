module OrientDB

  ClusterType            = com.orientechnologies.orient.core.storage.OStorage::CLUSTER_TYPE
  DocumentDatabase       = com.orientechnologies.orient.core.db.document.ODatabaseDocumentTx
  DocumentDatabasePool   = com.orientechnologies.orient.core.db.document.ODatabaseDocumentPool
  DocumentDatabasePooled = com.orientechnologies.orient.core.db.document.ODatabaseDocumentTxPooled
  Document               = com.orientechnologies.orient.core.record.impl.ODocument
  OClassImpl             = com.orientechnologies.orient.core.metadata.schema.OClassImpl
  LocalStorage           = com.orientechnologies.orient.core.storage.impl.local.OStorageLocal
  LocalCluster           = com.orientechnologies.orient.core.storage.impl.local.OClusterLocal
  LogicalCluster         = com.orientechnologies.orient.core.storage.impl.local.OClusterLogical
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

  STORAGE_TYPES = %w{ LOGICAL MEMORY PHYSICAL }.inject({ }) { |h, s| h[s.downcase.to_sym] = ClusterType.const_get s; h }

  FIELD_TYPES = {
    :binary        => "BINARY",
    :bool          => "BOOLEAN",
    :boolean       => "BOOLEAN",
    :double        => "BYTE",
    :date          => "DATE",
    :datetime      => "DATE",
    :decimal       => "FLOAT",
    :double        => "DOUBLE",
    :embedded      => "EMBEDDED",
    :embedded_list => "EMBEDDEDLIST",
    :list          => "EMBEDDEDLIST",
    :embedded_map  => "EMBEDDEDMAP",
    :map           => "EMBEDDEDMAP",
    :embedded_set  => "EMBEDDEDSET",
    :set           => "EMBEDDEDSET",
    :float         => "FLOAT",
    :int           => "INTEGER",
    :integer       => "INTEGER",
    :link          => "LINK",
    :link_list     => "LINKLIST",
    :link_map      => "LINKMAP",
    :link_set      => "LINKSET",
    :long          => "LONG",
    :short         => "SHORT",
    :string        => "STRING",
  }.inject({ }) do |h, (k, v)|
    h[k] = SchemaType.const_get v
    h
  end

end