# Only require this file if you don't mind polluting/monkeypatching to gain less typing
module OrientDB
  module SQL
    module OrderExtension
      def asc
        "#{to_s} ASC"
      end

      def desc
        "#{to_s} DESC"
      end
    end
  end
end

class Symbol
  include OrientDB::SQL::OrderExtension
end

class String
  include OrientDB::SQL::OrderExtension
end
