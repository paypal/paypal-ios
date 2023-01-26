import SwiftUI
import PaymentButtons

struct SwiftUIPaymentButtonDemo: View {

    @State private var pickerId = 0
    @State private var buttonId = 0

    @State private var fundingIndex = 0
    private var fundingSources = PaymentButtonFundingSource.allCasesAsString()
    @State private var selectedFunding = PaymentButtonFundingSource.allCases()[0]

    @State private var colorsIndex = 0
    @State private var colors = PayPalButton.Color.allCasesAsString()

    @State private var edgesIndex = 0
    private var edges = PaymentButtonEdges.allCasesAsString()
    @State private var selectedEdge = PaymentButtonEdges.allCases()[0]

    @State private var sizesIndex = 1
    private var sizes = PaymentButtonSize.allCasesAsString()
    @State private var selectedSize = PaymentButtonSize.allCases()[1]

    @ViewBuilder
    var body: some View {
        ZStack {
            VStack {
                Picker("Funding Source", selection: $fundingIndex) {
                    ForEach(fundingSources.indices, id: \.self) { index in
                        Text(fundingSources[index])
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .onChange(of: fundingIndex) { _ in
                    selectedFunding = PaymentButtonFundingSource.allCases()[fundingIndex]
                    colors = getColorFunding(with: selectedFunding)
                    colorsIndex = 0
                    pickerId += 1 // Workaround to change ID of picker. ID is updated to force refresh, https://developer.apple.com/forums/thread/127560
                    buttonId += 1
                }

                Picker("Colors", selection: $colorsIndex) {
                    ForEach(colors.indices, id: \.self) { index in
                        Text(colors[index])
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .onChange(of: colorsIndex) { _ in
                    buttonId += 1
                }
                .id(pickerId)

                Picker("Edges", selection: $edgesIndex) {
                    ForEach(edges.indices, id: \.self) { index in
                        Text(edges[index])
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .onChange(of: edgesIndex) { _ in
                    selectedEdge = PaymentButtonEdges.allCases()[edgesIndex]
                    buttonId += 1
                }

                Picker("sizes", selection: $sizesIndex) {
                    ForEach(sizes.indices, id: \.self) { index in
                        Text(sizes[index])
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .onChange(of: sizesIndex) { _ in
                    selectedSize = PaymentButtonSize.allCases()[sizesIndex]
                    buttonId += 1
                }

                switch selectedFunding {
                case .payPal:
                    PayPalButton.Representable(
                        color: PayPalButton.Color.allCases()[colorsIndex],
                        edges: selectedEdge,
                        size: selectedSize
                    )
                    .id(buttonId)

                case .payLater:
                    PayPalPayLaterButton.Representable(
                        color: PayPalPayLaterButton.Color.allCases()[colorsIndex],
                        edges: selectedEdge,
                        size: selectedSize
                    )
                    .id(buttonId)

                case .credit:
                    PayPalCreditButton.Representable(
                        color: PayPalCreditButton.Color.allCases()[colorsIndex],
                        edges: selectedEdge,
                        size: selectedSize
                    )
                    .id(buttonId)
                }
            }.padding()
        }
    }

    private func getColorFunding(with funding: PaymentButtonFundingSource) -> [String] {
        switch funding {
        case .payPal:
            return PayPalButton.Color.allCasesAsString()

        case .payLater:
            return PayPalPayLaterButton.Color.allCasesAsString()

        case .credit:
            return PayPalCreditButton.Color.allCasesAsString()
        }
    }
}
