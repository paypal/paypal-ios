import CardPayments

extension SCA: @retroactive CaseIterable {
    
    public static let allCases: [SCA] = [.scaAlways, .scaWhenRequired]
}
