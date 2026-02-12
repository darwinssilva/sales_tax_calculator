# frozen_string_literal: true

module SalesTaxCalculator
  # Represents a receipt containing a list of products with their calculated
  # taxes and total amounts.
  class Receipt
    ReceiptLineItem = Struct.new(:product, :price_with_tax) do
      def to_s
        "#{product}: #{format('%.2f', price_with_tax)}"
      end
    end

    attr_reader :line_items, :total_tax, :total_price

    def initialize(shopping_basket)
      raise ArgumentError, 'Shopping basket cannot be nil' if shopping_basket.nil?
      raise ArgumentError, 'Shopping basket must be a ShoppingBasket' unless shopping_basket.is_a?(ShoppingBasket)

      @line_items = build_line_items(shopping_basket)
      @total_tax = shopping_basket.total_tax.round(2)
      @total_price = shopping_basket.total_price.round(2)

      # Make the receipt immutable
      freeze
    end

    # Checks if receipt has any items
    # @return [Boolean]
    def empty?
      line_items.empty?
    end

    # Returns number of line items
    # @return [Integer]
    def size
      line_items.size
    end

    private

    def build_line_items(shopping_basket)
      items = []
      shopping_basket.each_product do |product|
        price_with_tax = shopping_basket.price_with_tax(product)
        items << ReceiptLineItem.new(product, price_with_tax.round(2))
      end
      items.freeze
    end
  end
end
