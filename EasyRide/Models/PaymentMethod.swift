import Foundation

struct PaymentMethod: Codable, Identifiable {
    let id: String
    let type: PaymentType
    let displayName: String
    let isDefault: Bool
    let lastFourDigits: String?
    let expiryDate: String?
    let isActive: Bool
    
    init(
        id: String = UUID().uuidString,
        type: PaymentType,
        displayName: String,
        isDefault: Bool = false,
        lastFourDigits: String? = nil,
        expiryDate: String? = nil,
        isActive: Bool = true
    ) {
        self.id = id
        self.type = type
        self.displayName = displayName
        self.isDefault = isDefault
        self.lastFourDigits = lastFourDigits
        self.expiryDate = expiryDate
        self.isActive = isActive
    }
}

enum PaymentType: String, Codable, CaseIterable {
    case applePay = "apple_pay"
    case wechatPay = "wechat_pay"
    case creditCard = "credit_card"
    case debitCard = "debit_card"
    case paypal = "paypal"
    case wallet = "wallet"
    
    var displayName: String {
        switch self {
        case .applePay: return "Apple Pay"
        case .wechatPay: return "WeChat Pay"
        case .creditCard: return "Credit Card"
        case .debitCard: return "Debit Card"
        case .paypal: return "PayPal"
        case .wallet: return "EasyRide Wallet"
        }
    }
    
    var icon: String {
        switch self {
        case .applePay: return "apple.logo"
        case .wechatPay: return "message.fill"
        case .creditCard: return "creditcard.fill"
        case .debitCard: return "creditcard"
        case .paypal: return "p.circle.fill"
        case .wallet: return "wallet.pass.fill"
        }
    }
    
    var requiresSetup: Bool {
        switch self {
        case .applePay, .wechatPay: return false
        case .creditCard, .debitCard, .paypal: return true
        case .wallet: return false
        }
    }
}