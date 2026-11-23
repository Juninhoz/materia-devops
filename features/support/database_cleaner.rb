# RSpec fixtures stay in the test database between runs, so truncate
# everything once before the suite.
BeforeAll do
  DatabaseCleaner.clean_with(:truncation)
end

# By default each scenario runs inside a transaction (see env.rb) that is
# rolled back at the end. With a real browser (BROWSER=chrome) the app runs in
# a separate server thread that can't see uncommitted data, so records are
# committed and the tables are truncated after each scenario instead.
DatabaseCleaner.strategy = :truncation if ENV["BROWSER"] == "chrome"
