import SwiftUI
import CardPayments
import CorePayments
import CardPaySheet

struct CardOrderApproveView: View {
    
    let orderID: String
    var config: CoreConfig?
    
    @ObservedObject var cardPaymentViewModel: CardPaymentViewModel
    @State private var cardNumberText: String = "4111 1111 1111 1111"
    @State private var expirationDateText: String = "01 / 25"
    @State private var cvvText: String = "123"
    @State private var showingCardSheet = false
    
    var body: some View {
        ScrollView {
            ScrollViewReader { scrollView in
                VStack {
                    VStack(spacing: 16) {
                        HStack {
                            Text("Your cart")
                                .font(.system(size: 22, weight: .semibold))
                            Spacer()
                        }
                        
                        HStack(spacing: 20) {
                            Image("headphonePic")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 120, height: 120)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Bose Rose Gold QC35II")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.primary)
                                Text("$10.00")
                                    .font(.system(size: 16))
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Spacer().frame(height: 20)
                        
                        Picker("SCA", selection: $cardPaymentViewModel.state.scaSelection) {
                            Text(SCA.scaWhenRequired.rawValue).tag(SCA.scaWhenRequired)
                            Text(SCA.scaAlways.rawValue).tag(SCA.scaAlways)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .frame(height: 50)
                        Button("Pay with Card") {
                            Task {
                                do {
                                    try await cardPaymentViewModel.getConfig()
                                    await MainActor.run {
                                        showingCardSheet = true
                                    }
                                }
                            }
                        }
                        .buttonStyle(RoundedBlueButtonStyle())
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(.gray, lineWidth: 2)
                            .padding(5)
                    )
                    CardApprovalResultView(cardPaymentViewModel: cardPaymentViewModel)
                    if cardPaymentViewModel.state.approveResult != nil {
                        NavigationLink {
                            CardPaymentOrderCompletionView(orderID: orderID, cardPaymentViewModel: cardPaymentViewModel)
                        } label: {
                            Text("Complete Order Transaction")
                        }
                        .buttonStyle(RoundedBlueButtonStyle())
                        .padding()
                    }
                    Text("")
                        .id("bottomView")
                    Spacer()
                }
                .sheet(isPresented: $showingCardSheet) {
                    if let config = cardPaymentViewModel.config {
                        CardPaySheetView(config: config, orderID: orderID, sca: cardPaymentViewModel.state.scaSelection) { result in
                            switch result {
                            case .success(let cardResult):
                                print("success!: \(cardResult.orderID)")
                                cardPaymentViewModel.setApprovalSuccessResult(
                                    approveResult:
                                        CardPaymentState.CardResult(
                                            id: cardResult.orderID,
                                            status: cardResult.status,
                                            didAttemptThreeDSecureAuthentication: cardResult.didAttemptThreeDSecureAuthentication
                                        )
                                )
                            case .failure(let error):
                                cardPaymentViewModel.setApprovalFailureResult(error: error)
                            }
                            showingCardSheet = false
                        }
                        .presentationDetents([.fraction(0.75)])
                    }
                }
                .onChange(of: cardPaymentViewModel.state) { _ in
                    withAnimation {
                        scrollView.scrollTo("bottomView")
                    }
                }
            }
        }
    }
}
