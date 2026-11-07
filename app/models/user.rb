class User < ApplicationRecord
  # Cadastro de usuários é feito pelo CRUD (somente usuários logados),
  # por isso o módulo :registerable não está habilitado.
  devise :database_authenticatable, :recoverable, :rememberable, :validatable

  validates :nome, presence: true, length: { maximum: 100 }
end
