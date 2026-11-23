Given("a user exists with email {string} and password {string}") do |email, password|
  User.create!(
    nome: "Administrator",
    email: email,
    document_number: "529.982.247-25",
    password: password,
    password_confirmation: password
  )
end

When("I sign in with email {string} and password {string}") do |email, password|
  visit new_user_session_path
  fill_in "E-mail", with: email
  fill_in "Senha", with: password
  click_button "Entrar"
end

Given("I am signed in as {string} with password {string}") do |email, password|
  step %(I sign in with email "#{email}" and password "#{password}")
  # Wait for the redirect to finish before reading the page (needed in a real browser)
  expect(page).to have_no_current_path(new_user_session_path)
  expect(page).to have_content("Login efetuado com sucesso.")
end
