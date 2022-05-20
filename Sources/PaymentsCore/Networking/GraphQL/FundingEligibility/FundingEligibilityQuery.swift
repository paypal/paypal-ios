//
//  FundingEligibilityQuery.swift
//  Card
//
//  Created by Andres Pelaez on 19/05/22.
//

class FundingEligibilityQuery: Query {
    
    typealias T = FundingEligibilityResponse
    
    var queryParams: Dictionary<String, String> {
        get {
            var queryParams = Dictionary<String, String>()
            queryParams[PARAM_CLIENT_ID] = clientId
            queryParams[PARAM_INTENT] = "\(fundingEligibilityIntent)"
            queryParams[PARAM_CURRENCY] = "\(currencyCode)"
            queryParams[PARAM_ENABLE_FUNDING] = "\(enableFunding)"
            
            return queryParams
        }
    }
    var queryName: String {
        get {
            "fundingEligibility"
        }
    }
    var dataFieldsForResponse: String {
        get {
            """
                {
                    paypal {
                        eligible
                        reasons
                    }
                    credit {
                        eligible
                        reasons
                    }
                    paylater {
                        eligible
                        reasons
                    }
                    card{
                        eligible
                    }
                     venmo{
                        eligible
                        reasons
                     }
                }
            """
        }
    }
    
    var clientId: String
    var fundingEligibilityIntent: FundingEligibilityIntent
    var currencyCode: SupportedCountryCurrencyType
    var enableFunding: [SupportedPaymentMethodsType]
    
    init(clientId: String, fundingEligibilityIntent: FundingEligibilityIntent,
         currencyCode: SupportedCountryCurrencyType, enableFunding: [SupportedPaymentMethodsType]
    ) {
        self.clientId = clientId
        self.fundingEligibilityIntent = fundingEligibilityIntent
        self.currencyCode = currencyCode
        self.enableFunding = enableFunding
    }
    
    let PARAM_CLIENT_ID = "clientId"
    let PARAM_INTENT = "intent"
    let PARAM_CURRENCY = "currency"
    let PARAM_ENABLE_FUNDING = "enableFunding"
    
    
}
