# typed: strict
# frozen_string_literal: true

module ShotgridApiRuby
  # Represent each entity returned by Shotgrid
  class Entity < T::Struct
    extend T::Sig

    # .new(:type, :attributes, :relationships, :id, :links) do
    const :type, String
    const :attributes, OpenStruct
    const :relationships, T::Hash[T.untyped, T.untyped]
    const :id, Integer
    const :links, T::Hash[String, String]

    sig do
      params(name: T.any(String, Symbol), args: T.untyped, block: T.untyped)
        .returns(T.untyped)
    end
    def method_missing(name, *args, &block)
      if attributes.respond_to?(name)
        define_singleton_method(name) { attributes.public_send(name) }
        public_send(name)
      else
        super
      end
    end

    sig do
      params(name: T.any(String, Symbol), _private_methods: T.untyped)
        .returns(T::Boolean)
    end
    def respond_to_missing?(name, _private_methods = false)
      attributes.respond_to?(name) || super
    end
  end
end
