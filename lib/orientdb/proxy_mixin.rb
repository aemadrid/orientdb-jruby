class OrientDB
  module ProxyMixin

    def self.included(base)
      base.extend ClassMethods
    end

    attr_reader :proxy_object

    def respond_to?(meth)
      proxy_object.respond_to?(meth) || super
    end

    def method_missing(meth, *args, &blk)
      if proxy_object.respond_to? meth
        puts "mm : #{meth}"
        proxy_object.send meth, *args, &blk
      else
        super
      end
    end

    alias_method :decorator_methods, :methods

    def methods
      (decorator_methods + proxy_object.methods).uniq
    end

    module ClassMethods

      def proxy_method(aliased_name, real_name = nil)
        real_name ||= aliased_name
        class_eval %{def #{aliased_name}(*args) puts "pm : #{real_name}"; proxy_object.send :#{real_name}, *args end}
      end

      def proxy_methods(*args)
        args.each { |arg| proxy_method *arg }
      end

      def proxy_accessor(aliased_name, real_name = nil)
        real_name    ||= aliased_name
        aliased_name = aliased_name.to_s
        if aliased_name[-1, 1] == '?'
          class_eval %{def #{aliased_name[0..-2]}() puts "pa : #{real_name}"; proxy_object.send :is_#{real_name}? end}
          class_eval %{def #{aliased_name}() puts "pa : #{real_name}"; proxy_object.send :is_#{real_name}? end}
          class_eval %{def #{aliased_name[0..-2]}=(v) puts "pa : #{real_name}"; proxy_object.send :set_#{real_name}, v end}
        else
          class_eval %{def #{aliased_name}() puts "pa : #{real_name}"; proxy_object.send :get_#{real_name}? end}
          class_eval %{def #{aliased_name}=(v) puts "pa : #{real_name}"; proxy_object.send :set_#{real_name}, v end}
        end
      end

      def proxy_accessors(*args)
        args.each { |arg| proxy_accessor *arg }
      end

      def self.const_missing(missing)
        puts "[#{name}:const_missing] #{missing}"
        super
      end

    end

  end
end