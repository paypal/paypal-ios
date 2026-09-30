import CardPayments

extension SCA: @retroactive CaseIterable {
    
    public static var allCases: [SCA] = [.scaAlways, .scaWhenRequired]
}
