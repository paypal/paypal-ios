enum URLResponseError: Error {
    case dataParsingError
    case networkConnectionError
    case serverError
    case invalidURL
}
