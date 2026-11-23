class User < ApplicationRecord
  devise :database_authenticatable, :recoverable, :rememberable, :validatable

  normalizes :document_number, with: ->(value) { value.gsub(/\D/, "") }

  validates :nome, presence: true, length: { maximum: 100 }
  validates :document_number, presence: true, uniqueness: true, cpf: true

  def formatted_document_number
    return if document_number.blank?

    document_number.sub(/\A(\d{3})(\d{3})(\d{3})(\d{2})\z/, '\1.\2.\3-\4')
  end

  def self.search(term)
    cleaned = term.to_s.strip
    return all if cleaned.blank?

    pattern = "%#{sanitize_sql_like(cleaned)}%"
    where("nome ILIKE :termo OR email ILIKE :termo", termo: pattern)
  end
end
