# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SalesTaxCalculator::Receipt do
  let(:tax_calculator) { SalesTaxCalculator::TaxCalculator.new }
  let(:basket) { SalesTaxCalculator::ShoppingBasket.new(tax_calculator: tax_calculator) }

  describe '#initialize' do
    context 'with empty basket' do
      it 'creates an empty receipt' do
        receipt = described_class.new(basket)

        expect(receipt.empty?).to be(true)
        expect(receipt.size).to eq(0)
        expect(receipt.total_tax).to eq(0.0)
        expect(receipt.total_price).to eq(0.0)
      end
    end

    context 'with products in basket' do
      before do
        book = SalesTaxCalculator::Product.new(name: 'book', base_price: 12.49, quantity: 2)
        cd = SalesTaxCalculator::Product.new(name: 'music CD', base_price: 14.99)
        chocolate = SalesTaxCalculator::Product.new(name: 'chocolate bar', base_price: 0.85)

        basket.add_products([book, cd, chocolate])
      end

      it 'creates receipt with line items' do
        receipt = described_class.new(basket)

        expect(receipt.empty?).to be(false)
        expect(receipt.size).to eq(3)
        expect(receipt.total_tax).to eq(1.50)
        expect(receipt.total_price).to eq(42.32)
      end

      it 'creates immutable receipt' do
        receipt = described_class.new(basket)
        expect(receipt).to be_frozen
      end

      it 'has correct line items' do
        receipt = described_class.new(basket)

        line_items = receipt.line_items
        expect(line_items[0].product.name).to eq('book')
        expect(line_items[0].price_with_tax).to eq(24.98)
        expect(line_items[1].product.name).to eq('music CD')
        expect(line_items[1].price_with_tax).to eq(16.49)
        expect(line_items[2].product.name).to eq('chocolate bar')
        expect(line_items[2].price_with_tax).to eq(0.85)
      end
    end

    it 'raises error for nil basket' do
      expect do
        described_class.new(nil)
      end.to raise_error(ArgumentError, 'Shopping basket cannot be nil')
    end

    it 'raises error for invalid basket' do
      expect do
        described_class.new('invalid')
      end.to raise_error(ArgumentError, 'Shopping basket must be a ShoppingBasket')
    end
  end

  describe 'ReceiptLineItem' do
    let(:product) { SalesTaxCalculator::Product.new(name: 'book', base_price: 12.49, quantity: 2) }
    let(:line_item) { described_class::ReceiptLineItem.new(product, 24.98) }

    describe '#to_s' do
      it 'formats line item correctly' do
        expect(line_item.to_s).to eq('2 book: 24.98')
      end

      it 'formats decimal prices correctly' do
        cd_product = SalesTaxCalculator::Product.new(name: 'music CD', base_price: 14.99)
        cd_line_item = described_class::ReceiptLineItem.new(cd_product, 16.49)

        expect(cd_line_item.to_s).to eq('1 music CD: 16.49')
      end
    end
  end
end
