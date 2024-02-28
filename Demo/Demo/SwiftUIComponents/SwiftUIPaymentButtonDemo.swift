import SwiftUI
import PaymentButtons

struct SwiftUIPaymentButtonDemo: View {

    @State private var pickerID = 0
    @State private var buttonID = 0

    @State private var fundingIndex = 0
    private var fundingSources = PaymentButtonFundingSource.allCasesAsString()
    @State private var selectedFunding = PaymentButtonFundingSource.allCases[0]

    @State private var colorsIndex = 0
    @State private var colors = PayPalButton.Color.allCasesAsString()

    @State private var edgesIndex = 0
    private var edges = PaymentButtonEdges.allCasesAsString()
    @State private var selectedEdge = PaymentButtonEdges.allCases[0]
    @State private var customEdge: Int = 10

    @State private var sizesIndex = 1
    private var sizes = PaymentButtonSize.allCasesAsString()
    @State private var selectedSize = PaymentButtonSize.allCases[1]
    
    @State private var labelIndex = 0
    private var labels = PayPalButton.Label.allCasesAsString()
    @State private var selectedLabel = PayPalButton.Label.allCases[0]

    @ViewBuilder var body: some View {
        ZStack {
            VStack {
                Picker("Funding Source", selection: $fundingIndex) {
                    ForEach(fundingSources.indices, id: \.self) { index in
                        Text(fundingSources[index])
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .onChange(of: fundingIndex) { _ in
                    selectedFunding = PaymentButtonFundingSource.allCases[fundingIndex]
                    colors = getColorFunding(with: selectedFunding)
                    colorsIndex = 0
                    pickerID += 1 // Workaround to change ID of picker. ID is updated to force refresh, https://developer.apple.com/forums/thread/127560
                    buttonID += 1
                }

                Picker("Colors", selection: $colorsIndex) {
                    ForEach(colors.indices, id: \.self) { index in
                        Text(colors[index])
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .onChange(of: colorsIndex) { _ in
                    buttonID += 1
                }
                .id(pickerID)

                Picker("Edges", selection: $edgesIndex) {
                    ForEach(edges.indices, id: \.self) { index in
                        Text(edges[index])
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .onChange(of: edgesIndex) { _ in
                    selectedEdge = PaymentButtonEdges.allCases[edgesIndex]
                    buttonID += 1
                }
                Stepper("Custom Corner Radius: \(customEdge)", value: $customEdge, in: 0...100).onChange(of: customEdge) { _ in
                    if selectedEdge.description == "custom" {
                        selectedEdge = PaymentButtonEdges.custom(CGFloat(customEdge))
                        buttonID += 1
                    }
                }
                Picker("sizes", selection: $sizesIndex) {
                    ForEach(sizes.indices, id: \.self) { index in
                        Text(sizes[index])
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .onChange(of: sizesIndex) { _ in
                    selectedSize = PaymentButtonSize.allCases[sizesIndex]
                    buttonID += 1
                }

                switch selectedFunding {
                case .payPal:
                    if selectedSize == .expanded || selectedSize == .full {
                        Picker("label", selection: $labelIndex) {
                            ForEach(labels.indices, id: \.self) { index in
                                Text(labels[index])
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .onChange(of: labelIndex) { _ in
                            selectedLabel = PayPalButton.Label.allCases[labelIndex]
                            buttonID += 1
                        }
                    }
                    PayPalButton.Representable(
                        color: PayPalButton.Color.allCases[colorsIndex],
                        edges: selectedEdge,
                        size: selectedSize,
                        label: selectedLabel
                    )
                    .id(buttonID)

                case .payLater:
                    PayPalPayLaterButton.Representable(
                        color: PayPalPayLaterButton.Color.allCases[colorsIndex],
                        edges: selectedEdge,
                        size: selectedSize
                    )
                    .id(buttonID)

                case .credit:
                    PayPalCreditButton.Representable(
                        color: PayPalCreditButton.Color.allCases[colorsIndex],
                        edges: selectedEdge,
                        size: selectedSize
                    )
                    .id(buttonID)
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity)
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

struct SwiftUIPaymentButtonDemo_Preview: PreviewProvider {
    
    static var previews: some View {
        SwiftUIPaymentButtonDemo()
    }
}
