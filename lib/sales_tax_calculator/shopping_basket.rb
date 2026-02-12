# frozen_string_literal: true

module SalesTaxCalculator
  # Manages a collection of products in a shopping basket.
  # Provides functionality to add products and iterate through them.
  class ShoppingBasket
    attr_reader :products

    def initialize(tax_calculator: TaxCalculator.new)
      @products = []
      @tax_calculator = tax_calculator
      @mutex = Mutex.new
    end

    def add_product(product)
      raise ArgumentError, 'Product must be a SalesTaxCalculator::Product' unless product.is_a?(Product)

      @mutex.synchronize do
        @products << product
      end

      self
    end

    def add_products(products)
      products.each { |product| add_product(product) }
      self
    end

    # Calculates total tax for all products in the basket
    # @return [Float]
    def total_tax
      @mutex.synchronize do
        @products.sum { |product| @tax_calculator.calculate_tax(product) }
      end
    end

    def total_price
      @mutex.synchronize do
        @products.sum { |product| @tax_calculator.calculate_price_with_tax(product) }
      end
    end

    def price_with_tax(product)
      @tax_calculator.calculate_price_with_tax(product)
    end

    def empty?
      @mutex.synchronize { @products.empty? }
    end

    def size
      @mutex.synchronize { @products.size }
    end

    def clear
      @mutex.synchronize do
        @products.clear
      end
      self
    end

    def each_product(&block)
      return enum_for(:each_product) unless block_given?

      products_copy = @mutex.synchronize { @products.dup }
      products_copy.each(&block)
    end
  end
end
