require "factory_boy/version"

module FactoryBoy
  @defined_factories = []

  def self.define_factory(klass, &block)
    @defined_factories << { klass: klass, default_block: block }
    true
  end

  def self.build(klass, attrs = {})
    defined_factory = @defined_factories.detect { |defined| defined[:klass] == klass }
    raise FactoryNotDefinedError unless defined_factory
    proxy = AttributesProxy.new
    proxy.instance_eval(&defined_factory[:default_block]) if defined_factory[:default_block]

    inst = klass.new
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
