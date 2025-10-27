import Foundation
@testable import CorePayments

class MockClientConfigAPI: UpdateClientConfigAPI {
    
    struct UpdateClientConfigArgs: Equatable {
        
        let token: String
        let fundingSource: String
    }
    
    var calls: [UpdateClientConfigArgs] = []
    
    override func updateClientConfig(token: String, fundingSource: String) {
        calls.append(UpdateClientConfigArgs(token: token, fundingSource: fundingSource))
    }
    
    func didCallUpdateClientConfig(withToken token: String, fundingSource: String) -> Bool {
        return calls.contains(UpdateClientConfigArgs(token: token, fundingSource: fundingSource))
    }
}
