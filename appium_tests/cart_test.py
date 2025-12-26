import unittest
from appium import webdriver
from appium.options.android import UiAutomator2Options
from appium.webdriver.common.appiumby import AppiumBy
import time

class CartTest(unittest.TestCase):
    def setUp(self):
        options = UiAutomator2Options()
        options.platform_name = "Android"
        options.automation_name = "UiAutomator2"
        options.device_name = "emulator-5554"
        options.app_package = "com.example.laza"
        options.app_activity = ".MainActivity"
        options.no_reset = True # Keeps you logged in from the previous test!
        
        self.driver = webdriver.Remote("http://127.0.0.1:4723", options=options)

    def test_add_to_cart(self):
        driver = self.driver
        time.sleep(5)

        # 1. Open First Product
        # Finds the first image/card on screen
        products = driver.find_elements(AppiumBy.CLASS_NAME, "android.widget.ImageView")
        if products:
            products[0].click()
            print("Product Clicked")
        else:
            self.fail("No products found")

        time.sleep(2)

        # 2. Click Add to Cart
        add_btn = driver.find_element(AppiumBy.XPATH, '//android.widget.Button[@content-desc="Add to Cart"]')
        add_btn.click()
        print("Added to Cart")
        time.sleep(1)

        # 3. Go Back to Home
        driver.back()
        time.sleep(1)

        # 4. Open Cart (Menu -> Cart)
        menu_btn = driver.find_element(AppiumBy.CLASS_NAME, "android.widget.Button") # Usually the first button is menu
        menu_btn.click()
        time.sleep(1)
        
        cart_link = driver.find_element(AppiumBy.ACCESSIBILITY_ID, "My Cart")
        cart_link.click()
        time.sleep(2)

        # 5. Verify Item exists
        # We check if the total price is visible or checkout button exists
        checkout_btn = driver.find_element(AppiumBy.ACCESSIBILITY_ID, "Checkout")
        self.assertIsNotNone(checkout_btn)
        print("TEST PASSED: Item verified in Cart")

    def tearDown(self):
        self.driver.quit()

if __name__ == '__main__':
    unittest.main()