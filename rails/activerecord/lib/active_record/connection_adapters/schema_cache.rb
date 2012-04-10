module ActiveRecord
  module ConnectionAdapters
    class SchemaCache
      attr_reader :columns, :columns_hash, :primary_keys, :tables, :version
      attr_accessor :connection

      def initialize(conn)
        @connection = conn

        @columns      = {}
        @columns_hash = {}
        @primary_keys = {}
        @tables       = {}
        prepare_default_proc
      end

      # A cached lookup for table existence.
      def table_exists?(name)
        return @tables[name] if @tables.key? name

        @tables[name] = connection.table_exists?(name)
      end

      # Add internal cache for table with +table_name+.
      def add(table_name)
        if table_exists?(table_name)
          @primary_keys[table_name]
          @columns[table_name]
          @columns_hash[table_name]
        end
      end

      # Clears out internal caches
      def clear!
        @columns.clear
        @columns_hash.clear
        @primary_keys.clear
        @tables.clear
        @version = nil
      end

      # Clear out internal caches for table with +table_name+.
      def clear_table_cache!(table_name)
        @columns.delete table_name
        @columns_hash.delete table_name
        @primary_keys.delete table_name
        @tables.delete table_name
      end

      def marshal_dump
        # if we get current version during initialization, it happens stack over flow.
        @version = ActiveRecord::Migrator.current_version
        [@version] + [:@columns, :@columns_hash, :@primary_keys, :@tables].map do |val|
          self.instance_variable_get(val).inject({}) { |h, v| h[v[0]] = v[1]; h }
        end
      end

      def marshal_load(array)
        @version, @columns, @columns_hash, @primary_keys, @tables = array
        prepare_default_proc
      end

      private

      def prepare_default_proc
        @columns.default_proc = Proc.new do |h, table_name|
          h[table_name] = connection.columns(table_name)
        end

        @columns_hash.default_proc = Proc.new do |h, table_name|
          h[table_name] = Hash[columns[table_name].map { |col|
            [col.name, col]
          }]
        end

        @primary_keys.default_proc = Proc.new do |h, table_name|
          h[table_name] = table_exists?(table_name) ? connection.primary_key(table_name) : nil
        end
      end
    end
  end
end
