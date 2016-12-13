require "factory_boy/version"

module FactoryBoy
  @defined_factories = []

  def self.define_factory(klass)
    @defined_factories << klass
    true
  end

  def self.build(klass, attrs = {})
    raise FactoryNotDefinedError unless @defined_factories.include?(klass)
    inst = klass.new
    attrs.each do |name, val|
      begin
        inst.public_send("#{name}=", val)
      rescue NoMethodError
        raise AttributeDoesNotExist
      end
    end
    inst
  end

  class FactoryNotDefinedError < StandardError; end
  class AttributeDoesNotExist < StandardError; end
end
