import Foundation

public enum APIResult<T> {
    case success(T)
    case failure(GraphQLError)
}
