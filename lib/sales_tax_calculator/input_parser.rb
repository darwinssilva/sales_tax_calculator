# frozen_string_literal: true

module SalesTaxCalculator
  # Parser class responsible for parsing input lines into Product objects.
  # Handles parsing of product names, quantities, prices, and import status.
  class InputParser
    INPUT_PATTERN = /^(\d+)\s+(.+?)\s+at\s+(\d+\.?\d*)$/

    def parse_line(line)
      validate_input(line)
      match = match_input_pattern(line)
      create_product_from_match(match)
    end

    def parse(input)
      lines = input.is_a?(String) ? input.split("\n") : input

      lines
        .map(&:strip)
        .reject(&:empty?)
        .map { |line| parse_line(line) }
    end

    private

    def validate_input(line)
      raise ArgumentError, 'Input line cannot be nil or empty' if line.nil? || line.strip.empty?
    end

    def match_input_pattern(line)
      line = line.strip
      match = INPUT_PATTERN.match(line)
      raise ArgumentError, "Invalid input format: '#{line}'" unless match

      match
    end

    def create_product_from_match(match)
      quantity = match[1].to_i
      product_name = match[2].strip
      price = match[3].to_f

      Product.new(
        name: product_name,
        base_price: price,
        quantity: quantity,
        imported: imported?(product_name)
      )
    end

    def imported?(product_name)
      product_name.downcase.include?('imported')
    end
  end
end
