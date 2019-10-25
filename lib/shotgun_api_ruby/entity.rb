# frozen_string_literal: true

module ShotgunApiRuby
  Entity =
    Struct.new(:type, :attributes, :relationships, :id, :links) do
      def method_missing(name, *args, &block)
        if attributes.respond_to?(name)
          define_singleton_method(name) do
            attributes.public_send(name)
          end
          public_send(name)
        else
          super
        end
      end

      def respond_to_missing?(name, _private_methods = false)
        attributes.respond_to?(name) || super
      end
    end
end
