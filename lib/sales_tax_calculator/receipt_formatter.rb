# frozen_string_literal: true

module SalesTaxCalculator
  # Formats receipts for display, showing product details, tax amounts,
  # and totals in a readable format.
  class ReceiptFormatter
    def format(receipt)
      raise ArgumentError, 'Receipt must be a SalesTaxCalculator::Receipt' unless receipt.is_a?(Receipt)

      return format_empty_receipt if receipt.empty?

      # Add line items
      lines = receipt.line_items.map(&:to_s)

      # Add tax and total
      lines << "Sales Taxes: #{format_as_currency(receipt.total_tax)}"
      lines << "Total: #{format_as_currency(receipt.total_price)}"

      lines.join("\n")
    end

    private

    def format_empty_receipt
      "Receipt is empty.\nSales Taxes: 0.00\nTotal: 0.00"
    end

    def format_as_currency(amount)
      rounded = amount.round(2)
      whole, decimal = rounded.to_s.split('.')
      decimal ||= '00'
      decimal = decimal.ljust(2, '0')[0, 2]
      "#{whole}.#{decimal}"
    end
  end
end
