//
//  CriticViewModel.swift
//  NYTMovieApp
//
//  Created by James Robinson on 29/01/2023.
//

import Foundation

class CriticViewModel: BaseViewModel, BaseViewModelProtocol {
    
    var reloadWith: ((ReloadType) -> Void)?
    var reviews = [Review]()
    
    let critic: Critic
    private let networkClient: NetworkClient
    private var hasMore = true
    private var loading = false
    
    init(critic: Critic, networkClient: NetworkClient = NetworkClient.shared) {
        self.critic = critic
        self.networkClient = networkClient
    }
    
    enum ReloadType {
        case reloadCollection
        case error(String)
    }
    
    func setup() {
        self.loadReviews()
    }
    
    func loadReviews(from: Int = 0) {
        self.networkClient.fetchReviews(from: from,
                                        reviewer: self.critic.displayName ?? "") { [weak self] result in
            self?.loading = false
            switch result {
            case .success(let response):
                if from == .zero {
                    self?.reviews = response.results ?? []
                } else {
                    self?.reviews.append(contentsOf: response.results ?? [])
                }
                self?.reloadWith?(.reloadCollection)
                self?.hasMore = response.hasMore ?? false
            case .failure(let error):
                self?.handleError(error: error)
            }
        }
    }
    
    func shouldLoadNextPage(index: Int) {
        let count = self.reviews.count
        guard self.hasMore,
              index + 2 > count,
              !self.loading else {
            return
        }
        
        self.loading = true
        self.loadReviews(from: count)
    }
    
    private func handleError(error: NetworkError) {
        if case .error(let string) = error {
            self.reloadWith?(.error(string))
        }
    }
}
