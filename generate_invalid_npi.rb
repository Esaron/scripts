#!/usr/bin/env ruby

RETRIES = 3.freeze
NPI_LEN = 10.freeze

def rand_npi
  "%0#{NPI_LEN}d" % rand(9_999_999_999)
end

def valid_luhn?(number)
  len = number.length
  parity = (len - 1) % 2
  digits = number.chars.map(&:to_i)
  check = digits.pop
  sum = digits.reverse.each_slice(2).flat_map do |x, y|
    [(x * 2).divmod(10), y || 0]
  end.flatten.inject(:+)
  check.zero? ? sum % 10 == 0 : (10 - sum % 10) == check
end

msg = "Unable to find an invalid npi in #{RETRIES} tries."

RETRIES.times do |x|
  npi = rand_npi
  unless valid_luhn? npi
    msg = npi
    break
  end
end

puts msg

