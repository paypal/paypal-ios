//
//  GetAccessToken.swift
//  Demo
//
//  Created by Jose Noriega on 30/08/2022.
//

import UIKit

final class GetAccessToken {
    func execute() async -> String? {
        await DemoMerchantAPI.sharedService.getAccessToken(environment: DemoSettings.environment)
    }
}
