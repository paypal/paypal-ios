import Foundation

struct UpdateClientConfigVariables: Encodable {
    
    let orderID: String
    let fundingSource: String
    let integrationArtifact: String
    let userExperienceFlow: String
    let productFlow: String
    let channel: String
}
