require 'factory_boy/version'
require 'factory_boy/errors'
require 'factory_boy/attributes_proxy'

module FactoryBoy
  @defined_factories = []

  def self.define_factory(klass_or_symbol, opts = {}, &block)
    @defined_factories <<
      case klass_or_symbol
      when Symbol
        begin
          klass = opts[:class] || Object.const_get(klass_or_symbol.to_s.split("_").map(&:capitalize).join)
          { name: klass_or_symbol, klass: klass, default_block: block }
        rescue NameError
          raise Errors::SymbolNotMatchingClassError
        end
      when Class
        { name: klass_or_symbol, klass: klass_or_symbol, default_block: block }
      else
        raise FactoryBoy::Errors::InvalidFactoryNameError
      end

    true
  end

  def self.build(klass_or_symbol, attrs = {})
    defined_factory = @defined_factories.detect { |defined| defined[:name] == klass_or_symbol }
    raise Errors::FactoryNotDefinedError unless defined_factory

    proxy = AttributesProxy.new
    proxy.instance_eval(&defined_factory[:default_block]) if defined_factory[:default_block]

    defined_factory[:klass].new.tap do |instance|
      proxy.attributes.merge(attrs).each do |name, val|
        begin
          instance.public_send("#{name}=", val)
        rescue NoMethodError
          if proxy.attributes.key?(name)
            raise Errors::DefaultAttributeDoesNotExistError
          else
            raise Errors::AttributeDoesNotExistError
          end
        end
      end
    end
  end
end
