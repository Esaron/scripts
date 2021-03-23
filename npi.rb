#!/usr/bin/env ruby

class Npi
  class << self
    def invalid
      generate_npi(valid: false)
    end

    def valid
      generate_npi
    end

    private

    MAGIC_PREFIX_SUM = 24

    def generate_npi(valid: true)
      npi_sans_check = rand_npi
      luhn_result = luhn(npi_sans_check.reverse)
      check_digit = check_digit(luhn_result)
      # If looking for an invalid npi, randomly use any digit other than the check digit.
      "#{npi_sans_check.join}#{valid ? check_digit : ([*0..9] - [check_digit]).sample}"
    end

    def luhn(digit_arr)
      # For each group of 2 digits, multiply the first digit by 2 and add together any digits in the result and take
      # the second digit as-is. Add all the resulting digits together and mod by 10.
      (digit_arr.each_slice(2).flat_map { |x, y| [(x * 2).divmod(10), y || 0] }.flatten.inject(:+) + MAGIC_PREFIX_SUM) % 10
    end

    def check_digit(luhn_result)
      # The digit needed to make the luhn mod operation yield 0 as a result
      (10 - luhn_result) % 10
    end

    def rand_luhn_candidate(digits:, include_check_digit: false)
      raise 'Must have at least 2 digits to be a valid luhn candidate' if digits < 2
      result_digits = include_check_digit ? digits : digits - 1
      npi = rand(10**(result_digits - 1))
      # NPI must start with a 1 or a 2 (digits reverses the order)
      npi_digits = npi.digits + [rand(0..1)]
      # Pad with zeroes
      npi_digits.reverse.fill(0, npi_digits.size..result_digits - 1)
    end

    def rand_npi
      rand_luhn_candidate(digits: 10)
    end

    def valid_luhn?(number_str)
      return false if number_str.length < 2
      digits = number_str.chars.map(&:to_i)
      check = digits.pop
      check_digit(luhn(digits.reverse)) == check
    end
  end
end

