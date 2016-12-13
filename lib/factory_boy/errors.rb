module FactoryBoy::Errors
  class FactoryNotDefinedError < StandardError; end
  class AttributeDoesNotExistError < StandardError; end
  class DefaultAttributeDoesNotExistError < StandardError; end
  class SymbolNotMatchingClassError < StandardError; end
  class InvalidFactoryNameError < StandardError; end
end
