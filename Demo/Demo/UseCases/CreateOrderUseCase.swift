
import Foundation
import PayPalNativeCheckout

final class CreateOrderUseCase {

    func execute(orderParams: CreateOrderParams) async -> Order? {
        do{
            return try await DemoMerchantAPI.sharedService.createOrder(orderParams: orderParams)
        }catch {
            print("❌ failed to fetch orderID: \(error)")
            return nil
        }
    }
}
