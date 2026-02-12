# frozen_string_literal: true

module SalesTaxCalculator
  # Calculates sales taxes for products based on their category and
  # import status. Implements rounding rules for tax calculations.
  class TaxCalculator
    BASIC_SALES_TAX_RATE = 0.10
    IMPORT_DUTY_RATE = 0.05
    ROUNDING_PRECISION = 0.05

    def calculate_tax(product)
      raise ArgumentError, 'Product must be a SalesTaxCalculator::Product' unless product.is_a?(Product)

      basic_tax = calculate_basic_tax(product)
      import_tax = calculate_import_tax(product)
      total_tax_per_unit = basic_tax + import_tax

      rounded_tax_per_unit = round_up_to_nearest_nickel(total_tax_per_unit)
      (rounded_tax_per_unit * product.quantity).round(2)
    end

    def calculate_price_with_tax(product)
      (product.total_base_price + calculate_tax(product)).round(2)
    end

    private

    def calculate_basic_tax(product)
      return 0.0 if product.tax_exempt?

      product.base_price * BASIC_SALES_TAX_RATE
    end

    def calculate_import_tax(product)
      return 0.0 unless product.imported?

      product.base_price * IMPORT_DUTY_RATE
    end

    def round_up_to_nearest_nickel(amount)
      ((amount / ROUNDING_PRECISION).ceil * ROUNDING_PRECISION).round(2)
    end
  end
end
