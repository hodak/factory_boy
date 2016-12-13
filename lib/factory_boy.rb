require "factory_boy/version"

module FactoryBoy
  @defined_factories = []

  def self.define_factory(klass)
    @defined_factories << klass
    true
  end

  def self.build(klass)
    raise FactoryNotDefinedError unless @defined_factories.include?(klass)
    klass.new
  end

  class FactoryNotDefinedError < StandardError
  end
end
