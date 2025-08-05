import Foundation
import SwiftUI
import Observation

@Observable
class ValueAddedServicesViewModel {
    var selectedServiceOptions: [ServiceOption] = []
    var availableCoupons: [Coupon] = []
    var appliedCoupon: Coupon?
    var priceBreakdown: PriceBreakdown = PriceBreakdown(baseFare: 0)
    var selectedPaymentMethod: PaymentMethod?
    var availablePaymentMethods: [PaymentMethod] = []
    var isLoading: Bool = false
    var showingCouponSheet: Bool = false
    
    // Charter-specific service selections
    var airportPickupSelected: Bool = false
    var checkinAssistanceSelected: Bool = false
    var tripSharingSelected: Bool = false
    var otherServicesSelected: Bool = false
    var childSeatSelected: Bool = false
    var interpreterSelected: Bool = false
    var elderlyCompanionSelected: Bool = false
    
    let baseFare: Double
    
    init(baseFare: Double = 500.0) {
        self.baseFare = baseFare
        setupDefaultData()
        calculatePricing()
    }
    
    private func setupDefaultData() {
        // Setup available service options
        let allServiceOptions = [
            ServiceOption.childSeat,
            ServiceOption.wifiHotspot,
            ServiceOption.premiumVehicle,
            ServiceOption.extraLuggage,
            ServiceOption.petFriendly,
            ServiceOption.wheelchairAccessible
        ]
        
        // Setup available coupons
        availableCoupons = [
            Coupon(
                code: "FIRST10",
                description: "10% off your first ride",
                discountAmount: 10,
                discountType: .percentage
            ),
            Coupon(
                code: "SAVE5",
                description: "$5 off rides over $20",
                discountAmount: 5,
                discountType: .fixedAmount
            ),
            Coupon(
                code: "WEEKEND",
                description: "15% off weekend rides",
                discountAmount: 15,
                discountType: .percentage
            )
        ]
        
        // Setup available payment methods
        availablePaymentMethods = [
            PaymentMethod(
                type: .applePay,
                displayName: "Apple Pay",
                isDefault: true
            ),
            PaymentMethod(
                type: .wechatPay,
                displayName: "WeChat Pay"
            ),
            PaymentMethod(
                type: .creditCard,
                displayName: "•••• 1234",
                lastFourDigits: "1234",
                expiryDate: "12/25"
            ),
            PaymentMethod(
                type: .wallet,
                displayName: "EasyRide Wallet ($45.20)"
            )
        ]
        
        selectedPaymentMethod = availablePaymentMethods.first { $0.isDefault }
    }
    
    func toggleServiceOption(_ option: ServiceOption) {
        withAnimation(.easeInOut(duration: 0.3)) {
            if let index = selectedServiceOptions.firstIndex(where: { $0.id == option.id }) {
                selectedServiceOptions.remove(at: index)
            } else {
                var updatedOption = option
                selectedServiceOptions.append(updatedOption)
            }
            calculatePricing()
        }
    }
    
    func isServiceOptionSelected(_ option: ServiceOption) -> Bool {
        selectedServiceOptions.contains { $0.id == option.id }
    }
    
    func applyCoupon(_ coupon: Coupon) {
        withAnimation(.easeInOut(duration: 0.3)) {
            appliedCoupon = coupon
            calculatePricing()
            showingCouponSheet = false
        }
    }
    
    func removeCoupon() {
        withAnimation(.easeInOut(duration: 0.3)) {
            appliedCoupon = nil
            calculatePricing()
        }
    }
    
    func selectPaymentMethod(_ method: PaymentMethod) {
        selectedPaymentMethod = method
    }
    
    private func calculatePricing() {
        let serviceFees = selectedServiceOptions.reduce(0) { $0 + $1.price }
        let taxes = (baseFare + serviceFees) * 0.08 // 8% tax
        
        var couponDiscount: Double = 0
        if let coupon = appliedCoupon {
            switch coupon.discountType {
            case .percentage:
                couponDiscount = (baseFare + serviceFees) * (coupon.discountAmount / 100)
            case .fixedAmount:
                couponDiscount = min(coupon.discountAmount, baseFare + serviceFees)
            }
        }
        
        priceBreakdown = PriceBreakdown(
            baseFare: baseFare,
            serviceFees: serviceFees,
            couponDiscount: couponDiscount,
            taxes: taxes
        )
    }
    
    var serviceFee: Double {
        return 50.0 // Fixed service fee
    }
    
    var totalAmount: Double {
        var total = baseFare + serviceFee
        
        if airportPickupSelected { total += 50.0 }
        if checkinAssistanceSelected { total += 30.0 }
        if childSeatSelected { total += 20.0 }
        if interpreterSelected { total += 100.0 }
        if elderlyCompanionSelected { total += 80.0 }
        
        return total
    }
    
    func getServiceOptionsByCategory() -> [ServiceOptionCategory: [ServiceOption]] {
        let allOptions = [
            ServiceOption.childSeat,
            ServiceOption.wifiHotspot,
            ServiceOption.premiumVehicle,
            ServiceOption.extraLuggage,
            ServiceOption.petFriendly,
            ServiceOption.wheelchairAccessible
        ]
        
        return Dictionary(grouping: allOptions) { $0.category }
    }
}