enum Intent: String, CaseIterable, Identifiable {
    case authorize = "AUTHORIZE"
    case capture = "CAPTURE"
    var id: Self { self }
}
