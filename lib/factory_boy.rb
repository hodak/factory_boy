require "factory_boy/version"

module FactoryBoy
  @defined_factories = []

  def self.define_factory(klass_or_symbol, &block)
    if klass_or_symbol.is_a? Symbol
      begin
        klass = Object.const_get(klass_or_symbol.to_s.split("_").map(&:capitalize).join)
        @defined_factories << { name: klass_or_symbol, klass: klass, default_block: block }
      rescue NameError
        raise SymbolNotMatchingClass
      end
    else
      @defined_factories << { name: klass_or_symbol, klass: klass_or_symbol, default_block: block }
    end

    true
  end

  def self.build(klass_or_symbol, attrs = {})
    defined_factory = @defined_factories.detect { |defined| defined[:name] == klass_or_symbol }
    raise FactoryNotDefinedError unless defined_factory
    proxy = AttributesProxy.new
    proxy.instance_eval(&defined_factory[:default_block]) if defined_factory[:default_block]

    inst = defined_factory[:klass].new
    proxy.attributes.merge(attrs).each do |name, val|
      begin
        inst.public_send("#{name}=", val)
      rescue NoMethodError
        if proxy.attributes.key?(name)
          raise DefaultAttributeDoesNotExist
        else
          raise AttributeDoesNotExist
        end
      end
    end
    inst
  end

  class FactoryNotDefinedError < StandardError; end
  class AttributeDoesNotExist < StandardError; end
  class DefaultAttributeDoesNotExist < StandardError; end
  class SymbolNotMatchingClass < StandardError; end

  class AttributesProxy < BasicObject
    attr_reader :attributes

    def initialize
      @attributes = {}
    end

    def method_missing(name, attr)
      @attributes[name] = attr
    end
  end
end
