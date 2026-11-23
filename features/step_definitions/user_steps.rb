When("I fill in the user form with:") do |table|
  table.rows_hash.each do |field, value|
    fill_in field, with: value
  end
end

Then("no user should exist with email {string}") do |email|
  expect(User.exists?(email: email)).to be(false)
end
