# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SalesTaxCalculator::TaxCalculator do
  let(:calculator) { described_class.new }

  describe '#calculate_tax' do
    it 'raises error for invalid product' do
      expect do
        calculator.calculate_tax('invalid')
      end.to raise_error(ArgumentError, 'Product must be a SalesTaxCalculator::Product')
    end

    context 'with tax-exempt products' do
      it 'calculates zero basic tax for books' do
        product = SalesTaxCalculator::Product.new(name: 'book', base_price: 12.49)
        tax = calculator.calculate_tax(product)

        expect(tax).to eq(0.0)
      end

      it 'calculates zero basic tax for food' do
        product = SalesTaxCalculator::Product.new(name: 'chocolate bar', base_price: 0.85)
        tax = calculator.calculate_tax(product)

        expect(tax).to eq(0.0)
      end

      it 'calculates zero basic tax for medical products' do
        product = SalesTaxCalculator::Product.new(name: 'headache pills', base_price: 9.75)
        tax = calculator.calculate_tax(product)

        expect(tax).to eq(0.0)
      end
    end

    context 'with taxable products' do
      it 'calculates 10% basic tax for non-exempt items' do
        product = SalesTaxCalculator::Product.new(name: 'music CD', base_price: 14.99)
        tax = calculator.calculate_tax(product)

        # 14.99 * 0.10 = 1.499, rounded up to nearest 0.05 = 1.50
        expect(tax).to eq(1.50)
      end
    end

    context 'with imported products' do
      it 'calculates 5% import duty on exempt products' do
        product = SalesTaxCalculator::Product.new(
          name: 'imported box of chocolates',
          base_price: 10.00,
          imported: true
        )
        tax = calculator.calculate_tax(product)

        # 10.00 * 0.05 = 0.50, rounded up to nearest 0.05 = 0.50
        expect(tax).to eq(0.50)
      end

      it 'calculates 15% total tax on non-exempt imported products' do
        product = SalesTaxCalculator::Product.new(
          name: 'imported bottle of perfume',
          base_price: 47.50,
          imported: true
        )
        tax = calculator.calculate_tax(product)

        # Basic: 47.50 * 0.10 = 4.75
        # Import: 47.50 * 0.05 = 2.375
        # Total: 7.125, rounded up to nearest 0.05 = 7.15
        expect(tax).to eq(7.15)
      end
    end

    context 'with multiple quantities' do
      it 'calculates tax for multiple items' do
        product = SalesTaxCalculator::Product.new(
          name: 'imported boxes of chocolates',
          base_price: 11.25,
          quantity: 3,
          imported: true
        )
        tax = calculator.calculate_tax(product)

        # Per unit: 11.25 * 0.05 = 0.5625, rounded up to 0.60
        # Total for 3: 0.60 * 3 = 1.80
        expect(tax).to eq(1.80)
      end
    end

    context 'rounding behavior' do
      it 'rounds up to nearest 0.05' do
        product = SalesTaxCalculator::Product.new(name: 'perfume', base_price: 18.99)
        tax = calculator.calculate_tax(product)

        # 18.99 * 0.10 = 1.899, rounded up to nearest 0.05 = 1.90
        expect(tax).to eq(1.90)
      end
    end
  end

  describe '#calculate_price_with_tax' do
    it 'returns base price plus tax' do
      product = SalesTaxCalculator::Product.new(name: 'music CD', base_price: 14.99)
      price = calculator.calculate_price_with_tax(product)

      # Base: 14.99, Tax: 1.50, Total: 16.49
      expect(price).to eq(16.49)
    end

    it 'handles multiple quantities correctly' do
      product = SalesTaxCalculator::Product.new(name: 'book', base_price: 12.49, quantity: 2)
      price = calculator.calculate_price_with_tax(product)

      # Base total: 24.98, Tax: 0.00, Total: 24.98
      expect(price).to eq(24.98)
    end
  end
end
