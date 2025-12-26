import unittest
from appium import webdriver
from appium.options.android import UiAutomator2Options
from appium.webdriver.common.appiumby import AppiumBy
import time

class AuthTest(unittest.TestCase):
    def setUp(self):
        options = UiAutomator2Options()
        options.platform_name = "Android"
        options.automation_name = "UiAutomator2"
        options.device_name = "emulator-5554"  # Check your emulator ID
        options.app_package = "com.example.laza"  # Your package name
        options.app_activity = ".MainActivity"
        options.no_reset = True
        
        self.driver = webdriver.Remote("http://127.0.0.1:4723", options=options)

    def test_signup_and_login(self):
        driver = self.driver
        # Wait for app to load
        time.sleep(5) 

        # 1. Click 'Create Account' on Welcome Screen
        try:
            # Note: Flutter keys often appear as resource-id or description
            # We use Accessibility ID which maps to Flutter Semantics/Keys
            create_btn = driver.find_element(AppiumBy.FLUTTER_INTEGRATION_KEY, "create_account_btn") 
            # If standard key doesn't work, we try finding by content desc
            # For this simple script, we assume Accessibility ID matches Key
        except:
            # Fallback for simple Flutter apps: Find by text
            el = driver.find_element(AppiumBy.XPATH, '//android.widget.Button[@content-desc="Create an Account"]')
            el.click()
        
        print("Navigated to Signup")
        time.sleep(2)

        # 2. Fill Signup Form
        email_input = driver.find_element(AppiumBy.XPATH, '//android.widget.EditText[1]')
        email_input.click()
        email_input.send_keys("testuser101@test.com")
        
        pass_input = driver.find_element(AppiumBy.XPATH, '//android.widget.EditText[2]')
        pass_input.click()
        pass_input.send_keys("password123")
        
        # Click Signup
        signup_btn = driver.find_element(AppiumBy.XPATH, '//android.widget.Button[@content-desc="Sign Up"]')
        signup_btn.click()
        
        print("Signup Clicked")
        time.sleep(5)
        
        # 3. Validation: Check if we are on Home Screen (Look for 'Hello')
        # In Flutter, Text widgets often become 'content-desc'
        home_text = driver.find_element(AppiumBy.ACCESSIBILITY_ID, "Hello")
        self.assertIsNotNone(home_text)
        print("TEST PASSED: Reached Home Screen")

    def tearDown(self):
        self.driver.quit()

if __name__ == '__main__':
    unittest.main()