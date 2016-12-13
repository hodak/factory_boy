module FactoryBoy
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
