# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SalesTaxCalculator::Application do
  let(:application) { described_class.new }

  describe '#initialize' do
    it 'uses default dependencies when none provided' do
      app = described_class.new
      expect(app).to be_a described_class
    end

    it 'accepts custom dependencies via dependency injection' do
      parser = double('InputParser')
      calculator = double('TaxCalculator')
      formatter = double('ReceiptFormatter')

      app = described_class.new(
        input_parser: parser,
        tax_calculator: calculator,
        receipt_formatter: formatter
      )

      expect(app).to be_a described_class
    end
  end

  describe '#process_input' do
    context 'with first test input' do
      let(:input) do
        <<~INPUT.strip
          2 book at 12.49
          1 music CD at 14.99
          1 chocolate bar at 0.85
        INPUT
      end

      it 'processes input correctly' do
        result = application.process_input(input)

        expected = <<~OUTPUT.strip
          2 book: 24.98
          1 music CD: 16.49
          1 chocolate bar: 0.85
          Sales Taxes: 1.50
          Total: 42.32
        OUTPUT

        expect(result).to eq(expected)
      end
    end

    context 'with second test input' do
      let(:input) do
        <<~INPUT.strip
          1 imported box of chocolates at 10.00
          1 imported bottle of perfume at 47.50
        INPUT
      end

      it 'processes imported products correctly' do
        result = application.process_input(input)

        expected = <<~OUTPUT.strip
          1 imported box of chocolates: 10.50
          1 imported bottle of perfume: 54.65
          Sales Taxes: 7.65
          Total: 65.15
        OUTPUT

        expect(result).to eq(expected)
      end
    end

    context 'with third test input' do
      let(:input) do
        <<~INPUT.strip
          1 imported bottle of perfume at 27.99
          1 bottle of perfume at 18.99
          1 packet of headache pills at 9.75
          3 imported boxes of chocolates at 11.25
        INPUT
      end

      it 'processes mixed products correctly' do
        result = application.process_input(input)

        expected = <<~OUTPUT.strip
          1 imported bottle of perfume: 32.19
          1 bottle of perfume: 20.89
          1 packet of headache pills: 9.75
          3 imported boxes of chocolates: 35.55
          Sales Taxes: 7.90
          Total: 98.38
        OUTPUT

        expect(result).to eq(expected)
      end
    end

    context 'with invalid input' do
      it 'handles errors gracefully' do
        result = application.process_input('invalid input')
        expect(result).to start_with('Error processing input:')
      end
    end

    context 'with empty input' do
      it 'handles empty input' do
        result = application.process_input('')

        expected = <<~OUTPUT.strip
          Receipt is empty.
          Sales Taxes: 0.00
          Total: 0.00
        OUTPUT

        expect(result).to eq(expected)
      end
    end
  end

  describe '#run' do
    it 'runs without errors' do
      # Capture stdout to test the output
      original_stdout = $stdout
      $stdout = StringIO.new

      expect { application.run }.not_to raise_error

      output = $stdout.string
      expect(output).to include('Sales Tax Calculator')
      expect(output).to include('Input 1:')
      expect(output).to include('Output 1:')
      expect(output).to include('42.32')
    ensure
      $stdout = original_stdout
    end
  end
end
