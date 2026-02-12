# Sales Tax Calculator

A Ruby application for calculating sales taxes, developed as a technical test following object-oriented programming principles and Ruby best practices.

## Overview

This application calculates sales tax with the following rules:

- **Basic sales tax**: 10% on all goods, except books, food, and medical products (which are exempt)
- **Import duty**: Additional 5% tax on all imported goods (no exemptions)
- **Rounding**: For a tax rate of n%, a shelf price of p contains (np/100 rounded up to the nearest 0.05) amount of sales tax

## Requirements

- Ruby 3.2+
- Bundler

## Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd sales_tax_calculator
```

2. Install dependencies:
```bash
bundle install
```

## Usage

### Run the Application

```bash
ruby main.rb
```

This will execute the three predefined test cases and display the formatted output.

### Run Tests

```bash
# Run all tests
bundle exec rspec

# Run with detailed format
bundle exec rspec --format documentation

# Run specific test
bundle exec rspec spec/lib/sales_tax_calculator/product_spec.rb
```

## Architecture

The project follows object-oriented programming principles with high cohesion and low coupling:

### Main Classes

#### `Product`
- Represents an individual product
- Immutable and thread-safe
- Automatically identifies exempt and imported products

#### `TaxCalculator`
- Calculates taxes for products
- Implements rounding rules
- Stateless and thread-safe

#### `ShoppingBasket`
- Contains products using composition
- Thread-safe with Mutex
- Calculates totals using TaxCalculator

#### `Receipt`
- Represents an immutable receipt
- Contains line items and totals
- Separated from formatting (SRP)

#### `ReceiptFormatter`
- Formats receipts for display
- Stateless
- Easily replaceable (Strategy Pattern)

#### `InputParser`
- Parses text input
- Converts strings to Product objects
- Robust error handling

#### `Application`
- Orchestrates all components
- Uses dependency injection
- Easy to test and extend
