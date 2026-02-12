# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SalesTaxCalculator::Product do
  describe '#initialize' do
    it 'creates a product with valid parameters' do
      product = described_class.new(name: 'book', base_price: 12.49, quantity: 2)

      expect(product.name).to eq('book')
      expect(product.base_price).to eq(12.49)
      expect(product.quantity).to eq(2)
      expect(product.imported).to be(false)
    end

    it 'creates an imported product' do
      product = described_class.new(name: 'imported perfume', base_price: 47.50, imported: true)

      expect(product.imported).to be(true)
      expect(product.imported?).to be(true)
    end

    it 'defaults quantity to 1' do
      product = described_class.new(name: 'chocolate', base_price: 0.85)

      expect(product.quantity).to eq(1)
    end

    it 'validates price is positive' do
      expect do
        described_class.new(name: 'book', base_price: -1)
      end.to raise_error(ArgumentError, 'Price must be positive')
    end

    it 'validates price is numeric' do
      expect do
        described_class.new(name: 'book', base_price: 'invalid')
      end.to raise_error(ArgumentError, 'Price must be numeric')
    end

    it 'validates quantity is positive' do
      expect do
        described_class.new(name: 'book', base_price: 12.49, quantity: 0)
      end.to raise_error(ArgumentError, 'Quantity must be positive')
    end

    it 'makes the product immutable' do
      product = described_class.new(name: 'book', base_price: 12.49)
      expect(product).to be_frozen
    end
  end

  describe '#tax_exempt?' do
    it 'returns true for books' do
      product = described_class.new(name: 'book', base_price: 12.49)
      expect(product.tax_exempt?).to be(true)
    end

    it 'returns true for food items' do
      product = described_class.new(name: 'chocolate bar', base_price: 0.85)
      expect(product.tax_exempt?).to be(true)
    end

    it 'returns true for medical products' do
      product = described_class.new(name: 'headache pills', base_price: 9.75)
      expect(product.tax_exempt?).to be(true)
    end

    it 'returns false for non-exempt items' do
      product = described_class.new(name: 'music CD', base_price: 14.99)
      expect(product.tax_exempt?).to be(false)
    end

    it 'is case insensitive' do
      product = described_class.new(name: 'Book', base_price: 12.49)
      expect(product.tax_exempt?).to be(true)
    end
  end

  describe '#total_base_price' do
    it 'calculates total for single item' do
      product = described_class.new(name: 'book', base_price: 12.49, quantity: 1)
      expect(product.total_base_price).to eq(12.49)
    end

    it 'calculates total for multiple items' do
      product = described_class.new(name: 'book', base_price: 12.49, quantity: 2)
      expect(product.total_base_price).to eq(24.98)
    end
  end

  describe '#to_s' do
    it 'returns string representation' do
      product = described_class.new(name: 'book', base_price: 12.49, quantity: 2)
      expect(product.to_s).to eq('2 book')
    end
  end
end
