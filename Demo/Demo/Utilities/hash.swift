
func hash(_ values: any Hashable...) -> Int {
    var hasher = Hasher()
    for value in values {
        hasher.combine(value)
    }
    return hasher.finalize()
}
