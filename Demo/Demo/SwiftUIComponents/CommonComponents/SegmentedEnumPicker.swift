import SwiftUI

struct SegmentedEnumPicker<T: RawRepresentable<String> & Hashable & CaseIterable>: View {
    
    let label: String
    let selection: Binding<T>
    private let values = Array(T.allCases)
    
    var body: some View {
        Picker(label, selection: selection) {
            ForEach(values, id: \.hashValue) { value in
                Text(value.rawValue).tag(value)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
    }
}
