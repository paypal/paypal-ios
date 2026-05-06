enum AsyncState<T> {

    case idle
    case loading
    case error(message: String)
    case loaded(_ value: T)
    
    var value: T? {
        switch self {
        case .loaded(let value): return value
        default: return nil
        }
    }
    var isLoading: Bool {
        switch self {
        case .loading:
            return true
        default:
            return false
        }
    }
}
