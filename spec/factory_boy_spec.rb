require "spec_helper"
require 'factory_boy'

class TestUser
  attr_accessor :name
end

describe FactoryBoy do
  before do
    FactoryBoy.instance_variable_set(:@defined_factories, [])
  end

  describe ".define_factory" do
    it "can define factory" do
      expect(FactoryBoy.define_factory(TestUser)).to eql true
    end
  end

  describe ".build" do
    it "raises error when factory wasn't defined" do
      expect { FactoryBoy.build(TestUser) }.to raise_error(FactoryBoy::FactoryNotDefinedError)
    end

    it "returns instance of given class when factory was defined" do
      FactoryBoy.define_factory(TestUser)
      user = FactoryBoy.build(TestUser)
      expect(user).to be_instance_of(TestUser)
    end

    it "can set attributes" do
      FactoryBoy.define_factory(TestUser)
      user = FactoryBoy.build(TestUser, name: "foobar")
      expect(user.name).to eql "foobar"
    end

    it "fails when attribute doesn't exist" do
      FactoryBoy.define_factory(TestUser)
      expect { FactoryBoy.build(TestUser, hodor: "foobar") }.to raise_error(FactoryBoy::AttributeDoesNotExist)
    end

    describe "default attributes set" do
      it "can set default attributes" do
        FactoryBoy.define_factory(TestUser) do
          name "foobar"
        end
        user = FactoryBoy.build(TestUser)
        expect(user.name).to eql "foobar"
      end

      it "raises error when default attribute doesn't exist" do
        FactoryBoy.define_factory(TestUser) do
          hodor "foobar"
        end
        expect { user = FactoryBoy.build(TestUser) }.to raise_error(FactoryBoy::DefaultAttributeDoesNotExist)
      end

      it "raises error about default attribute when attribute is missing both from defaults and passed in arg" do
        FactoryBoy.define_factory(TestUser) do
          hodor "foobar"
        end
        expect { user = FactoryBoy.build(TestUser, hodor: "hodor") }
          .to raise_error(FactoryBoy::DefaultAttributeDoesNotExist)
      end

      it "can overwrite default attributes in .build" do
        FactoryBoy.define_factory(TestUser) do
          name "foobar"
        end
        user = FactoryBoy.build(TestUser, name: "FOOBAR")
        expect(user.name).to eql "FOOBAR"
      end
    end
  end
end
