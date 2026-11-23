# Maps readable page names used in the features to application paths.
module NavigationHelpers
  def path_to(page_name)
    case page_name
    when "users" then users_path
    when "new user" then new_user_path
    when "sign in" then new_user_session_path
    else raise ArgumentError, "No path mapped for the \"#{page_name}\" page"
    end
  end
end
World(NavigationHelpers)

Given("I am on the new user page") do
  visit path_to("new user")
end

When("I visit the {word} page") do |page_name|
  visit path_to(page_name)
end

When("I click {string}") do |text|
  click_on text
end

Then("I should see {string}") do |text|
  expect(page).to have_content(text)
end

Then("I should be on the users page") do
  # The users list is also the root page
  expect([ root_path, users_path ]).to include(URI.parse(current_url).path)
end

Then("I should be on the sign in page") do
  expect(page).to have_current_path(new_user_session_path)
end
