require 'active_record/connection_adapters/abstract_mysql_adapter'

class ActiveRecord::ConnectionAdapters::AbstractMysqlAdapter
  NATIVE_DATABASE_TYPES[:primary_key] = "int(11) auto_increment PRIMARY KEY"
end
