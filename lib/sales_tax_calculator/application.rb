# frozen_string_literal: true

module SalesTaxCalculator
  # Main application class that orchestrates the sales tax calculation process
  # by parsing inputs, calculating taxes, and formatting receipts.
  class Application
    def initialize(
      input_parser: InputParser.new,
      tax_calculator: TaxCalculator.new,
      receipt_formatter: ReceiptFormatter.new
    )
      @input_parser = input_parser
      @tax_calculator = tax_calculator
      @receipt_formatter = receipt_formatter
    end

    # Runs the application with predefined test inputs
    def run
      display_header
      process_all_test_inputs
    end

    # Processes a single input and returns formatted receipt
    # @param input [String] input to process
    # @return [String] formatted receipt
    def process_input(input)
      products = @input_parser.parse(input)
      basket = ShoppingBasket.new(tax_calculator: @tax_calculator)
      basket.add_products(products)

      receipt = Receipt.new(basket)
      @receipt_formatter.format(receipt)
    rescue StandardError => e
      "Error processing input: #{e.message}"
    end

    private

    def display_header
      puts 'Sales Tax Calculator'
      puts '==================='
      puts
    end

    def process_all_test_inputs
      test_inputs.each_with_index do |input, index|
        process_single_test_input(input, index)
      end
    end

    def process_single_test_input(input, index)
      puts "Input #{index + 1}:"
      puts input
      puts

      puts "Output #{index + 1}:"
      puts process_input(input)
      puts
    end

    def test_inputs
      [input1, input2, input3]
    end

    def input1
      <<~INPUT.strip
        2 book at 12.49
        1 music CD at 14.99
        1 chocolate bar at 0.85
      INPUT
    end

    def input2
      <<~INPUT.strip
        1 imported box of chocolates at 10.00
        1 imported bottle of perfume at 47.50
      INPUT
    end

    def input3
      <<~INPUT.strip
        1 imported bottle of perfume at 27.99
        1 bottle of perfume at 18.99
        1 packet of headache pills at 9.75
        3 imported boxes of chocolates at 11.25
      INPUT
    end
  end
end
