Feature: Authentication
  As a registered user
  I want to sign in and sign out
  So that only authorized people can access the system

  Background:
    Given a user exists with email "admin@example.com" and password "password123"

  Scenario: Signing in with valid credentials
    When I sign in with email "admin@example.com" and password "password123"
    Then I should see "Login efetuado com sucesso."
    And I should be on the users page

  Scenario: Signing in with an invalid password
    When I sign in with email "admin@example.com" and password "wrong-password"
    Then I should see "E-mail ou senha inválidos."
    And I should be on the sign in page

  Scenario: Accessing a protected page without signing in
    When I visit the users page
    Then I should be on the sign in page

  Scenario: Signing out
    Given I am signed in as "admin@example.com" with password "password123"
    When I click "Sair"
    Then I should see "Logout efetuado com sucesso."
    And I should be on the sign in page
