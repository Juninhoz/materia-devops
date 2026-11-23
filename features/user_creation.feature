Feature: User creation
  As a signed in user
  I want to register new users
  So that other people can access the system

  Background:
    Given a user exists with email "admin@example.com" and password "password123"
    And I am signed in as "admin@example.com" with password "password123"
    And I am on the new user page

  Scenario: Creating a user with valid data
    When I fill in the user form with:
      | Nome                 | Maria Silva       |
      | E-mail               | maria@example.com |
      | CPF                  | 111.444.777-35    |
      | Senha                | password123       |
      | Confirmação de senha | password123       |
    And I click "Salvar"
    Then I should see "Usuário criado com sucesso."
    And I should see "Maria Silva"
    And I should see "111.444.777-35"

  Scenario: Creating a user with an invalid CPF
    When I fill in the user form with:
      | Nome                 | Maria Silva       |
      | E-mail               | maria@example.com |
      | CPF                  | 111.444.777-00    |
      | Senha                | password123       |
      | Confirmação de senha | password123       |
    And I click "Salvar"
    Then I should see "CPF não é válido"
    And no user should exist with email "maria@example.com"

  # Runs without a browser: in a real browser the HTML "required" attribute
  # blocks the submission before it reaches the server-side validation.
  @rack_test
  Scenario: Creating a user without filling in the required fields
    When I click "Salvar"
    Then I should see "Nome não pode ficar em branco"
    And I should see "CPF não pode ficar em branco"
