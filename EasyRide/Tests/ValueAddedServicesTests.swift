import XCTest
@testable import EasyRide

final class ValueAddedServicesTests: XCTestCase {
    
    var viewModel: ValueAddedServicesViewModel!
    
    override func setUp() {
        super.setUp()
        viewModel = ValueAddedServicesViewModel(baseFare: 25.0)
    }
    
    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }
    
    func testInitialState() {
        // Test initial state
        XCTAssertEqual(viewModel.selectedServiceOptions.count, 0)
        XCTAssertNil(viewModel.appliedCoupon)
        XCTAssertEqual(viewModel.priceBreakdown.baseFare, 25.0)
        XCTAssertEqual(viewModel.priceBreakdown.serviceFees, 0.0)
        XCTAssertEqual(viewModel.priceBreakdown.couponDiscount, 0.0)
        XCTAssertNotNil(viewModel.selectedPaymentMethod)
    }
    
    func testServiceOptionToggle() {
        let childSeat = ServiceOption.childSeat
        
        // Test adding service option
        viewModel.toggleServiceOption(childSeat)
        XCTAssertTrue(viewModel.isServiceOptionSelected(childSeat))
        XCTAssertEqual(viewModel.selectedServiceOptions.count, 1)
        XCTAssertEqual(viewModel.priceBreakdown.serviceFees, childSeat.price)
        
        // Test removing service option
        viewModel.toggleServiceOption(childSeat)
        XCTAssertFalse(viewModel.isServiceOptionSelected(childSeat))
        XCTAssertEqual(viewModel.selectedServiceOptions.count, 0)
        XCTAssertEqual(viewModel.priceBreakdown.serviceFees, 0.0)
    }
    
    func testCouponApplication() {
        let coupon = Coupon(
            code: "TEST10",
            description: "10% off test coupon",
            discountAmount: 10,
            discountType: .percentage
        )
        
        // Test applying coupon
        viewModel.applyCoupon(coupon)
        XCTAssertNotNil(viewModel.appliedCoupon)
        XCTAssertEqual(viewModel.appliedCoupon?.code, "TEST10")
        XCTAssertGreaterThan(viewModel.priceBreakdown.couponDiscount, 0)
        
        // Test removing coupon
        viewModel.removeCoupon()
        XCTAssertNil(viewModel.appliedCoupon)
        XCTAssertEqual(viewModel.priceBreakdown.couponDiscount, 0)
    }
    
    func testPriceCalculation() {
        let baseFare = 25.0
        let childSeat = ServiceOption.childSeat // $5.00
        let wifiHotspot = ServiceOption.wifiHotspot // $3.00
        
        // Add service options
        viewModel.toggleServiceOption(childSeat)
        viewModel.toggleServiceOption(wifiHotspot)
        
        let expectedServiceFees = childSeat.price + wifiHotspot.price
        let expectedTaxes = (baseFare + expectedServiceFees) * 0.08
        let expectedTotal = baseFare + expectedServiceFees + expectedTaxes
        
        XCTAssertEqual(viewModel.priceBreakdown.serviceFees, expectedServiceFees, accuracy: 0.01)
        XCTAssertEqual(viewModel.priceBreakdown.taxes, expectedTaxes, accuracy: 0.01)
        XCTAssertEqual(viewModel.priceBreakdown.total, expectedTotal, accuracy: 0.01)
    }
    
    func testPriceCalculationWithCoupon() {
        let baseFare = 25.0
        let childSeat = ServiceOption.childSeat // $5.00
        let coupon = Coupon(
            code: "SAVE5",
            description: "$5 off",
            discountAmount: 5,
            discountType: .fixedAmount
        )
        
        // Add service option and coupon
        viewModel.toggleServiceOption(childSeat)
        viewModel.applyCoupon(coupon)
        
        let subtotal = baseFare + childSeat.price
        let expectedDiscount = 5.0
        let expectedTaxes = (subtotal - expectedDiscount) * 0.08
        let expectedTotal = subtotal - expectedDiscount + expectedTaxes
        
        XCTAssertEqual(viewModel.priceBreakdown.couponDiscount, expectedDiscount, accuracy: 0.01)
        XCTAssertEqual(viewModel.priceBreakdown.total, expectedTotal, accuracy: 0.01)
    }
    
    func testPaymentMethodSelection() {
        let applePay = PaymentMethod(type: .applePay, displayName: "Apple Pay", isDefault: true)
        let wechatPay = PaymentMethod(type: .wechatPay, displayName: "WeChat Pay")
        
        // Test selecting payment method
        viewModel.selectPaymentMethod(wechatPay)
        XCTAssertEqual(viewModel.selectedPaymentMethod?.type, .wechatPay)
        
        // Test selecting back to Apple Pay
        viewModel.selectPaymentMethod(applePay)
        XCTAssertEqual(viewModel.selectedPaymentMethod?.type, .applePay)
    }
    
    func testServiceOptionsByCategory() {
        let servicesByCategory = viewModel.getServiceOptionsByCategory()
        
        // Verify all categories are present
        XCTAssertTrue(servicesByCategory.keys.contains(.safety))
        XCTAssertTrue(servicesByCategory.keys.contains(.convenience))
        XCTAssertTrue(servicesByCategory.keys.contains(.premium))
        XCTAssertTrue(servicesByCategory.keys.contains(.comfort))
        
        // Verify specific services are in correct categories
        let safetyServices = servicesByCategory[.safety] ?? []
        XCTAssertTrue(safetyServices.contains { $0.name == "Child Seat" })
        XCTAssertTrue(safetyServices.contains { $0.name == "Wheelchair Accessible" })
        
        let convenienceServices = servicesByCategory[.convenience] ?? []
        XCTAssertTrue(convenienceServices.contains { $0.name == "WiFi Hotspot" })
        XCTAssertTrue(convenienceServices.contains { $0.name == "Extra Luggage" })
    }
}