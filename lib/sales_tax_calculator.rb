# frozen_string_literal: true

# Sales Tax Calculator module that provides functionality to calculate
# sales taxes, manage shopping baskets, and format receipts.
module SalesTaxCalculator
  require_relative 'sales_tax_calculator/product'
  require_relative 'sales_tax_calculator/tax_calculator'
  require_relative 'sales_tax_calculator/shopping_basket'
  require_relative 'sales_tax_calculator/receipt'
  require_relative 'sales_tax_calculator/receipt_formatter'
  require_relative 'sales_tax_calculator/input_parser'
  require_relative 'sales_tax_calculator/application'
end
