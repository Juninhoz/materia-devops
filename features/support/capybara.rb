# Capybara configuration for Cucumber scenarios.
#
# By default scenarios run with :rack_test (fast, no real browser, no JavaScript)
# and @javascript scenarios run in headless Chrome.
#
# Set BROWSER=chrome to run every scenario in a visible Chrome window:
#   BROWSER=chrome bundle exec cucumber
# Set SLOW_MO (seconds) to pause after each step and follow along:
#   BROWSER=chrome SLOW_MO=1 bundle exec cucumber
if ENV["BROWSER"] == "chrome"
  Capybara.default_driver = :selenium_chrome
  Capybara.javascript_driver = :selenium_chrome
else
  Capybara.default_driver = :rack_test
  Capybara.javascript_driver = :selenium_chrome_headless
end

Capybara.default_max_wait_time = 5

if ENV["SLOW_MO"].present?
  AfterStep { sleep ENV["SLOW_MO"].to_f }
end

# Workaround: Capybara 3.40 resets Chrome sessions with
# Storage.clearDataForOrigin(origin: "*"), which recent Chrome versions reject
# ("* is not a valid URL"). When that happens, clear the cookies through
# another DevTools command so the next scenario still starts signed out.
require "capybara/selenium/driver"
require "capybara/selenium/driver_specializations/chrome_driver"

module ChromeSessionResetFix
  def reset!
    super
  rescue Selenium::WebDriver::Error::InvalidArgumentError => e
    raise unless e.message.include?("is not a valid URL")

    execute_cdp("Network.clearBrowserCookies")
  end
end
Capybara::Selenium::Driver::ChromeDriver.prepend(ChromeSessionResetFix)
