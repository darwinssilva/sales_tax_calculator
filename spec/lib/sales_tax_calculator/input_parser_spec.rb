# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SalesTaxCalculator::InputParser do
  let(:parser) { described_class.new }

  describe '#parse_line' do
    it 'parses a simple product line' do
      product = parser.parse_line('2 book at 12.49')

      expect(product.name).to eq('book')
      expect(product.base_price).to eq(12.49)
      expect(product.quantity).to eq(2)
      expect(product.imported?).to be(false)
    end

    it 'parses a line with decimal price' do
      product = parser.parse_line('1 chocolate bar at 0.85')

      expect(product.name).to eq('chocolate bar')
      expect(product.base_price).to eq(0.85)
      expect(product.quantity).to eq(1)
    end

    it 'parses an imported product' do
      product = parser.parse_line('1 imported box of chocolates at 10.00')

      expect(product.name).to eq('imported box of chocolates')
      expect(product.base_price).to eq(10.00)
      expect(product.quantity).to eq(1)
      expect(product.imported?).to be(true)
    end

    it 'parses multiple imported items' do
      product = parser.parse_line('3 imported boxes of chocolates at 11.25')

      expect(product.name).to eq('imported boxes of chocolates')
      expect(product.base_price).to eq(11.25)
      expect(product.quantity).to eq(3)
      expect(product.imported?).to be(true)
    end

    it 'handles products with complex names' do
      product = parser.parse_line('1 bottle of perfume at 18.99')

      expect(product.name).to eq('bottle of perfume')
      expect(product.base_price).to eq(18.99)
      expect(product.quantity).to eq(1)
      expect(product.imported?).to be(false)
    end

    it 'handles medical products' do
      product = parser.parse_line('1 packet of headache pills at 9.75')

      expect(product.name).to eq('packet of headache pills')
      expect(product.base_price).to eq(9.75)
      expect(product.quantity).to eq(1)
      expect(product.imported?).to be(false)
    end

    it 'handles prices without decimals' do
      product = parser.parse_line('1 item at 15')

      expect(product.base_price).to eq(15.0)
    end

    it 'raises error for nil input' do
      expect do
        parser.parse_line(nil)
      end.to raise_error(ArgumentError, 'Input line cannot be nil or empty')
    end

    it 'raises error for empty input' do
      expect do
        parser.parse_line('')
      end.to raise_error(ArgumentError, 'Input line cannot be nil or empty')
    end

    it 'raises error for whitespace-only input' do
      expect do
        parser.parse_line('   ')
      end.to raise_error(ArgumentError, 'Input line cannot be nil or empty')
    end

    it 'raises error for invalid format' do
      expect do
        parser.parse_line('invalid format')
      end.to raise_error(ArgumentError, "Invalid input format: 'invalid format'")
    end

    it 'raises error for missing price' do
      expect do
        parser.parse_line('2 book at')
      end.to raise_error(ArgumentError, "Invalid input format: '2 book at'")
    end

    it 'raises error for missing quantity' do
      expect do
        parser.parse_line('book at 12.49')
      end.to raise_error(ArgumentError, "Invalid input format: 'book at 12.49'")
    end

    it 'trims whitespace from input' do
      product = parser.parse_line('  2 book at 12.49  ')

      expect(product.name).to eq('book')
      expect(product.quantity).to eq(2)
      expect(product.base_price).to eq(12.49)
    end
  end

  describe '#parse' do
    context 'with string input' do
      let(:input) do
        <<~INPUT
          2 book at 12.49
          1 music CD at 14.99
          1 chocolate bar at 0.85
        INPUT
      end

      it 'parses multiple lines from string' do
        products = parser.parse(input)

        expect(products.length).to eq(3)
        expect(products[0].name).to eq('book')
        expect(products[1].name).to eq('music CD')
        expect(products[2].name).to eq('chocolate bar')
      end
    end

    context 'with array input' do
      let(:input) do
        [
          '2 book at 12.49',
          '1 music CD at 14.99',
          '1 chocolate bar at 0.85'
        ]
      end

      it 'parses multiple lines from array' do
        products = parser.parse(input)

        expect(products.length).to eq(3)
        expect(products[0].name).to eq('book')
        expect(products[1].name).to eq('music CD')
        expect(products[2].name).to eq('chocolate bar')
      end
    end

    it 'handles empty lines' do
      input = "2 book at 12.49\n\n1 music CD at 14.99"
      products = parser.parse(input)

      expect(products.length).to eq(2)
      expect(products[0].name).to eq('book')
      expect(products[1].name).to eq('music CD')
    end

    it 'handles whitespace-only lines' do
      input = "2 book at 12.49\n   \n1 music CD at 14.99"
      products = parser.parse(input)

      expect(products.length).to eq(2)
      expect(products[0].name).to eq('book')
      expect(products[1].name).to eq('music CD')
    end

    it 'returns empty array for empty input' do
      expect(parser.parse('')).to eq([])
      expect(parser.parse([])).to eq([])
    end
  end
end
