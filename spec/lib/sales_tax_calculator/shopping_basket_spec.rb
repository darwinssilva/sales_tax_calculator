# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SalesTaxCalculator::ShoppingBasket do
  let(:tax_calculator) { SalesTaxCalculator::TaxCalculator.new }
  let(:basket) { described_class.new(tax_calculator: tax_calculator) }

  describe '#initialize' do
    it 'creates an empty basket' do
      expect(basket.empty?).to be(true)
      expect(basket.size).to eq(0)
    end

    it 'uses default tax calculator if none provided' do
      default_basket = described_class.new
      expect(default_basket.empty?).to be(true)
    end
  end

  describe '#add_product' do
    let(:product) { SalesTaxCalculator::Product.new(name: 'book', base_price: 12.49) }

    it 'adds a product to the basket' do
      basket.add_product(product)

      expect(basket.empty?).to be(false)
      expect(basket.size).to eq(1)
    end

    it 'returns self for chaining' do
      result = basket.add_product(product)
      expect(result).to eq(basket)
    end

    it 'raises error for invalid product' do
      expect do
        basket.add_product('invalid')
      end.to raise_error(ArgumentError, 'Product must be a SalesTaxCalculator::Product')
    end
  end

  describe '#add_products' do
    let(:product1) { SalesTaxCalculator::Product.new(name: 'book', base_price: 12.49) }
    let(:product2) { SalesTaxCalculator::Product.new(name: 'CD', base_price: 14.99) }

    it 'adds multiple products' do
      basket.add_products([product1, product2])

      expect(basket.size).to eq(2)
    end

    it 'returns self for chaining' do
      result = basket.add_products([product1, product2])
      expect(result).to eq(basket)
    end
  end

  describe '#total_tax' do
    it 'calculates total tax for all products' do
      book = SalesTaxCalculator::Product.new(name: 'book', base_price: 12.49, quantity: 2)
      cd = SalesTaxCalculator::Product.new(name: 'music CD', base_price: 14.99)
      chocolate = SalesTaxCalculator::Product.new(name: 'chocolate bar', base_price: 0.85)

      basket.add_products([book, cd, chocolate])

      # Book: 0 tax (exempt), CD: 1.50 tax, Chocolate: 0 tax (exempt)
      expect(basket.total_tax).to eq(1.50)
    end

    it 'returns 0 for empty basket' do
      expect(basket.total_tax).to eq(0.0)
    end
  end

  describe '#total_price' do
    it 'calculates total price including tax' do
      book = SalesTaxCalculator::Product.new(name: 'book', base_price: 12.49, quantity: 2)
      cd = SalesTaxCalculator::Product.new(name: 'music CD', base_price: 14.99)
      chocolate = SalesTaxCalculator::Product.new(name: 'chocolate bar', base_price: 0.85)

      basket.add_products([book, cd, chocolate])

      # Book: 24.98, CD: 16.49, Chocolate: 0.85, Total: 42.32
      expect(basket.total_price).to eq(42.32)
    end

    it 'returns 0 for empty basket' do
      expect(basket.total_price).to eq(0.0)
    end
  end

  describe '#price_with_tax' do
    it 'returns price with tax for specific product' do
      product = SalesTaxCalculator::Product.new(name: 'music CD', base_price: 14.99)
      price = basket.price_with_tax(product)

      expect(price).to eq(16.49)
    end
  end

  describe '#clear' do
    it 'removes all products from basket' do
      product = SalesTaxCalculator::Product.new(name: 'book', base_price: 12.49)
      basket.add_product(product)

      expect(basket.empty?).to be(false)

      result = basket.clear
      expect(basket.empty?).to be(true)
      expect(result).to eq(basket)
    end
  end

  describe '#each_product' do
    let(:product1) { SalesTaxCalculator::Product.new(name: 'book', base_price: 12.49) }
    let(:product2) { SalesTaxCalculator::Product.new(name: 'CD', base_price: 14.99) }

    it 'iterates over products' do
      basket.add_products([product1, product2])

      collected = []
      basket.each_product { |product| collected << product }

      expect(collected).to contain_exactly(product1, product2)
    end

    it 'returns enumerator when no block given' do
      basket.add_products([product1, product2])
      enumerator = basket.each_product

      expect(enumerator).to be_a(Enumerator)
      expect(enumerator.to_a).to contain_exactly(product1, product2)
    end

    it 'is thread-safe' do
      basket.add_products([product1, product2])

      # This would raise an error if not thread-safe during iteration
      expect do
        basket.each_product do |product|
          # Simulate concurrent modification attempt
          Thread.new { basket.add_product(product) }.join
        end
      end.not_to raise_error
    end
  end
end
