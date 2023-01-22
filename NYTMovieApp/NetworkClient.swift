import Foundation

enum NetworkError: Error {
    case urlError
    case networkError(Error)
    case error(String)
}

class NetworkClient {
    
    static let shared = NetworkClient()
    
    // private init to force use of shared
    private init() {}
    
    /// A method to perform api call to NYT api
    ///
    /// - Parameters:
    /// - Model: model of object in response
    /// - Path: path of api call
    /// - Queries: Query parameters for api call
    private func performApiCall<T: Codable>(model: T.Type,
                                            path: String? = nil,
                                            queries: [URLQueryItem]? = nil,
                                            completion: @escaping (Result<T, NetworkError>) -> Void) {
        var components = URLComponents()
        components.scheme = "https"
        components.host = Constants.API.host
        
        if let path = path {
            components.path = path
        }
        
        var queryItems = [URLQueryItem(name: "api-key", value: Constants.API.key)]
        if let queries = queries {
            queryItems.append(contentsOf: queries)
        }
        components.queryItems = queryItems
        
        guard let URL = components.url else {
            completion(.failure(.urlError))
            return
        }
        
        URLSession.shared.dataTask(with: URL) { data, response, error in
            if let error = error {
                completion(.failure(.networkError(error)))
                return
            }
            
            if let errorMessage = self.errorMessage(from: response) {
                completion(.failure(.error(errorMessage)))
                return
            }
            
            if let data = data {
                do {
                    let decoded = try JSONDecoder().decode(model, from: data)
                    completion(.success(decoded))
                } catch let error {
                    print(error)
                }
            }
        }.resume()
    }
    
    func fetchReviews(from: Int,
                      search: String? = nil,
                      reviewer: String? = nil,
                      completion: @escaping (Result<Reviews, NetworkError>) -> Void) {
        let queries = self.queryItems(from: from, search: search, reviewer: reviewer)
        self.performApiCall(model: Reviews.self,
                            path: Constants.API.reviews,
                            queries: queries,
                            completion: completion)
    }
    
    func fetchCritics(from: Int,
                      search: String? = nil,
                      completion: @escaping (Result<Critics, NetworkError>) -> Void) {
        let queries = self.queryItems(from: from, search: search)
        self.performApiCall(model: Critics.self,
                            path: Constants.API.critics,
                            queries: queries,
                            completion: completion)
    }
    
    private func queryItems(from: Int, search: String?, reviewer: String? = nil) -> [URLQueryItem] {
        var items = [URLQueryItem]()
        if let search = search,
           !search.isEmpty {
            items.append(URLQueryItem(name: "query", value: search))
        }
        if let reviewer = reviewer,
           !reviewer.isEmpty {
            items.append(URLQueryItem(name: "reviewer", value: reviewer))
        }
        items.append(URLQueryItem(name: "offset", value: String(from)))
        return items
    }
    
    private func errorMessage(from: URLResponse?) -> String? {
        guard let httpResponse = from as? HTTPURLResponse else {
            return nil
        }
        
        switch httpResponse.statusCode {
        case 429:
            return "Rate limit reached - rerun app"
        default:
            return nil
        }
    }
}
