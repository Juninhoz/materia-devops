# Valida um CPF pelos dígitos verificadores.
# Espera o valor já normalizado (somente dígitos).
#
#   validates :document_number, cpf: true
class CpfValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank?

    record.errors.add(attribute, options[:message] || :invalid) unless self.class.valid?(value)
  end

  def self.valid?(value)
    digits = value.to_s.gsub(/\D/, "")
    return false unless digits.match?(/\A\d{11}\z/)
    # Sequências repetidas (000.000.000-00, 111.111.111-11...) passam no cálculo mas são inválidas
    return false if digits.chars.uniq.size == 1

    numbers = digits.chars.map(&:to_i)
    check_digit(numbers.first(9)) == numbers[9] && check_digit(numbers.first(10)) == numbers[10]
  end

  def self.check_digit(numbers)
    weights = (2..numbers.size + 1).to_a.reverse
    remainder = numbers.zip(weights).sum { |n, w| n * w } * 10 % 11
    remainder == 10 ? 0 : remainder
  end
  private_class_method :check_digit
end
