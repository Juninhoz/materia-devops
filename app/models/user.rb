class User < ApplicationRecord
  # Cadastro de usuários é feito pelo CRUD (somente usuários logados),
  # por isso o módulo :registerable não está habilitado.
  devise :database_authenticatable, :recoverable, :rememberable, :validatable

  validates :nome, presence: true, length: { maximum: 100 }

  def self.search(term)
    cleaned = term.to_s.strip
    return all if cleaned.blank?

    pattern = "%#{sanitize_sql_like(cleaned)}%"
    where("nome ILIKE :termo OR email ILIKE :termo", termo: pattern)
  end
end
