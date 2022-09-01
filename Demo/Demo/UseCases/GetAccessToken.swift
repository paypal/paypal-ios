import UIKit

final class GetAccessToken {
    func execute() async -> String? {
        await DemoMerchantAPI.sharedService.getAccessToken(environment: DemoSettings.environment)
    }
}
