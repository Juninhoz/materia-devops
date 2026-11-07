# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Usuário inicial para acessar o sistema (altere a senha após o primeiro login)
User.find_or_create_by!(email: "admin@example.com") do |user|
  user.nome = "Administrador"
  user.password = "senha123"
  user.password_confirmation = "senha123"
end
