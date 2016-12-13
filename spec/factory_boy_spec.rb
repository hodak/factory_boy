require "spec_helper"

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

    it "can receive symbol" do
      expect(FactoryBoy.define_factory(:test_user)).to eql true
    end

    it "raises error when symbol doesn't match any existing class" do
      expect { FactoryBoy.define_factory(:hodor) }
        .to raise_error(FactoryBoy::Errors::SymbolNotMatchingClassError)
    end

    it "can receive hash with options" do
      expect(FactoryBoy.define_factory(:test_user, class: TestUser)).to eql true
    end

    it "raises error when passed different first argument than class or symbol" do
      expect { FactoryBoy.define_factory(1, class: TestUser) }
        .to raise_error(FactoryBoy::Errors::InvalidFactoryNameError)
    end
  end

  describe ".build" do
    it "raises error when factory wasn't defined" do
      expect { FactoryBoy.build(TestUser) }
        .to raise_error(FactoryBoy::Errors::FactoryNotDefinedError)
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
      expect { FactoryBoy.build(TestUser, hodor: "foobar") }
        .to raise_error(FactoryBoy::Errors::AttributeDoesNotExistError)
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
        expect { user = FactoryBoy.build(TestUser) }
          .to raise_error(FactoryBoy::Errors::DefaultAttributeDoesNotExistError)
      end

      it "raises error about default attribute when attribute is missing both from defaults and passed in arg" do
        FactoryBoy.define_factory(TestUser) do
          hodor "foobar"
        end
        expect { user = FactoryBoy.build(TestUser, hodor: "hodor") }
          .to raise_error(FactoryBoy::Errors::DefaultAttributeDoesNotExistError)
      end

      it "can overwrite default attributes in .build" do
        FactoryBoy.define_factory(TestUser) do
          name "foobar"
        end
        user = FactoryBoy.build(TestUser, name: "FOOBAR")
        expect(user.name).to eql "FOOBAR"
      end
    end

    describe "symbols" do
      it "builds object instantiated from class from symbol name" do
        FactoryBoy.define_factory(:test_user)
        user = FactoryBoy.build(:test_user)
        expect(user).is_a?(TestUser)
      end

      it "doesn't build when factory was defined with symbol but called with class" do
        FactoryBoy.define_factory(:test_user)
        expect { FactoryBoy.build(TestUser) }
          .to raise_error(FactoryBoy::Errors::FactoryNotDefinedError)
      end

      it "builds object based on class given in options" do
        FactoryBoy.define_factory(:admin, class: TestUser)
        expect(FactoryBoy.build(:admin)).is_a?(TestUser)
      end
    end
  end
end
