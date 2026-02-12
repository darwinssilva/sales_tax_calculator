# frozen_string_literal: true

module SalesTaxCalculator
  # Represents a product with its properties like name, price, quantity,
  # and import status. Handles tax exemption logic based on product categories.
  class Product
    TAX_EXEMPT_CATEGORIES = %w[book food medical chocolate pill].freeze

    attr_reader :name, :base_price, :quantity, :imported

    def initialize(name:, base_price:, quantity: 1, imported: false)
      @name = name.to_s.freeze
      @base_price = validate_price(base_price)
      @quantity = validate_quantity(quantity)
      @imported = imported
      freeze
    end

    def tax_exempt?
      TAX_EXEMPT_CATEGORIES.any? { |category| name.downcase.include?(category) }
    end

    def imported?
      imported
    end

    def total_base_price
      base_price * quantity
    end

    def to_s
      "#{quantity} #{name}"
    end

    private

    def validate_price(price)
      raise ArgumentError, 'Price must be numeric' unless price.is_a?(Numeric)
      raise ArgumentError, 'Price must be positive' if price <= 0

      price.to_f.round(2)
    end

    def validate_quantity(quantity)
      raise ArgumentError, 'Quantity must be numeric' unless quantity.is_a?(Numeric)
      raise ArgumentError, 'Quantity must be positive' if quantity <= 0

      quantity.to_i
    end
  end
end
