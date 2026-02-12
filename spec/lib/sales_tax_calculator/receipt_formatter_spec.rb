# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SalesTaxCalculator::ReceiptFormatter do
  let(:formatter) { described_class.new }
  let(:tax_calculator) { SalesTaxCalculator::TaxCalculator.new }
  let(:basket) { SalesTaxCalculator::ShoppingBasket.new(tax_calculator: tax_calculator) }

  describe '#format' do
    it 'raises error for invalid receipt' do
      expect do
        formatter.format('invalid')
      end.to raise_error(ArgumentError, 'Receipt must be a SalesTaxCalculator::Receipt')
    end

    context 'with empty receipt' do
      it 'formats empty receipt' do
        receipt = SalesTaxCalculator::Receipt.new(basket)
        formatted = formatter.format(receipt)

        expected = "Receipt is empty.\nSales Taxes: 0.00\nTotal: 0.00"
        expect(formatted).to eq(expected)
      end
    end

    context 'with products in basket' do
      before do
        book = SalesTaxCalculator::Product.new(name: 'book', base_price: 12.49, quantity: 2)
        cd = SalesTaxCalculator::Product.new(name: 'music CD', base_price: 14.99)
        chocolate = SalesTaxCalculator::Product.new(name: 'chocolate bar', base_price: 0.85)

        basket.add_products([book, cd, chocolate])
      end

      it 'formats receipt correctly' do
        receipt = SalesTaxCalculator::Receipt.new(basket)
        formatted = formatter.format(receipt)

        expected = <<~RECEIPT.strip
          2 book: 24.98
          1 music CD: 16.49
          1 chocolate bar: 0.85
          Sales Taxes: 1.50
          Total: 42.32
        RECEIPT

        expect(formatted).to eq(expected)
      end
    end

    context 'with imported products' do
      before do
        chocolates = SalesTaxCalculator::Product.new(
          name: 'imported box of chocolates',
          base_price: 10.00,
          imported: true
        )
        perfume = SalesTaxCalculator::Product.new(
          name: 'imported bottle of perfume',
          base_price: 47.50,
          imported: true
        )

        basket.add_products([chocolates, perfume])
      end

      it 'formats imported products receipt correctly' do
        receipt = SalesTaxCalculator::Receipt.new(basket)
        formatted = formatter.format(receipt)

        expected = <<~RECEIPT.strip
          1 imported box of chocolates: 10.50
          1 imported bottle of perfume: 54.65
          Sales Taxes: 7.65
          Total: 65.15
        RECEIPT

        expect(formatted).to eq(expected)
      end
    end

    context 'with mixed products' do
      before do
        imported_perfume = SalesTaxCalculator::Product.new(
          name: 'imported bottle of perfume',
          base_price: 27.99,
          imported: true
        )
        perfume = SalesTaxCalculator::Product.new(
          name: 'bottle of perfume',
          base_price: 18.99
        )
        pills = SalesTaxCalculator::Product.new(
          name: 'packet of headache pills',
          base_price: 9.75
        )
        chocolates = SalesTaxCalculator::Product.new(
          name: 'imported boxes of chocolates',
          base_price: 11.25,
          quantity: 3,
          imported: true
        )

        basket.add_products([imported_perfume, perfume, pills, chocolates])
      end

      it 'formats mixed products receipt correctly' do
        receipt = SalesTaxCalculator::Receipt.new(basket)
        formatted = formatter.format(receipt)

        expected = <<~RECEIPT.strip
          1 imported bottle of perfume: 32.19
          1 bottle of perfume: 20.89
          1 packet of headache pills: 9.75
          3 imported boxes of chocolates: 35.55
          Sales Taxes: 7.90
          Total: 98.38
        RECEIPT

        expect(formatted).to eq(expected)
      end
    end
  end
end
