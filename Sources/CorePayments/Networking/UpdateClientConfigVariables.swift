import Foundation

struct UpdateClientConfigVariables: Encodable {
    
    let token: String
    let fundingSource: String
    let integrationArtifact: String
    let userExperienceFlow: String
    let productFlow: String
    let channel: String
}
