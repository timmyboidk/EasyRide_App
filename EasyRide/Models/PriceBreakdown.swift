import Foundation

struct PriceBreakdown: Codable {
    let baseFare: Double
    let serviceFees: Double
    let couponDiscount: Double
    let taxes: Double
    let total: Double
    
    init(baseFare: Double, serviceFees: Double = 0, couponDiscount: Double = 0, taxes: Double = 0) {
        self.baseFare = baseFare
        self.serviceFees = serviceFees
        self.couponDiscount = couponDiscount
        self.taxes = taxes
        self.total = baseFare + serviceFees - couponDiscount + taxes
    }
    
    var formattedBaseFare: String {
        return String(format: "$%.2f", baseFare)
    }
    
    var formattedServiceFees: String {
        return String(format: "$%.2f", serviceFees)
    }
    
    var formattedCouponDiscount: String {
        return String(format: "-$%.2f", couponDiscount)
    }
    
    var formattedTaxes: String {
        return String(format: "$%.2f", taxes)
    }
    
    var formattedTotal: String {
        return String(format: "$%.2f", total)
    }
}

struct Coupon: Codable, Identifiable {
    let id: String
    let code: String
    let description: String
    let discountAmount: Double
    let discountType: DiscountType
    let isApplied: Bool
    let expiryDate: Date?
    
    init(
        id: String = UUID().uuidString,
        code: String,
        description: String,
        discountAmount: Double,
        discountType: DiscountType,
        isApplied: Bool = false,
        expiryDate: Date? = nil
    ) {
        self.id = id
        self.code = code
        self.description = description
        self.discountAmount = discountAmount
        self.discountType = discountType
        self.isApplied = isApplied
        self.expiryDate = expiryDate
    }
    
    var formattedDiscount: String {
        switch discountType {
        case .percentage:
            return "\(Int(discountAmount))% off"
        case .fixedAmount:
            return String(format: "$%.2f off", discountAmount)
        }
    }
}

enum DiscountType: String, Codable {
    case percentage = "percentage"
    case fixedAmount = "fixed_amount"
}