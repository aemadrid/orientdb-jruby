module OrientDB
  module Mixins
    module Proxy

      def self.included(base)
        base.extend ClassMethods
      end

      attr_reader :proxy_object

      def respond_to?(meth)
        proxy_object.respond_to?(meth) || super
      end

      def method_missing(meth, *args, &blk)
        if proxy_object.respond_to? meth
          proxy_object.send meth, *args, &blk
        else
          super
        end
      end

      module ClassMethods

        def proxy_accessor(aliased_name, real_name = nil)
          real_name ||= aliased_name
          aliased_name = aliased_name.to_s
          if aliased_name[-1,1] == '?'
            class_eval %{def #{aliased_name[0..-2]}() proxy_object.send :is_#{real_name}? end}
            class_eval %{def #{aliased_name}() proxy_object.send :is_#{real_name}? end}
            class_eval %{def #{aliased_name[0..-2]}=(v) proxy_object.send :set_#{real_name}, v end}
          else
            class_eval %{def #{aliased_name}() proxy_object.send :get_#{real_name}? end}
            class_eval %{def #{aliased_name}=(v) proxy_object.send :set_#{real_name}, v end}
          end
        end

        def proxy_accessors(*args)
          args.each { |arg| proxy_accessor *arg }
        end

      end

    end
  end
end