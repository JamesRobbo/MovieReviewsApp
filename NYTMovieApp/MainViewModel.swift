import Foundation

class MainViewModel: BaseViewModel, BaseViewModelProtocol {
    
    private let networkClient: NetworkClient
    
    var reviews = [Review]()
    private var originalReviews = [Review]()
    var critics = [Critic]()
    var currentTab: Tab = .reviews {
        didSet {
            self.reloadWith?(.tabChange)
            self.reloadData()
        }
    }
    
    private var hasMore = true
    private var loading = false
    private var currentSearchText: String?
    
    var reloadWith: ((ReloadType) -> Void)?
    
    enum ReloadType {
        case reloadCollection
        case noResults
        case tabChange
        case error(String)
    }
    
    init(networkClient: NetworkClient = NetworkClient.shared) {
        self.networkClient = networkClient
    }
    
    // MARK: - Public methods
    
    func loadReviews(from: Int = 0) {
        self.networkClient.fetchReviews(from: from,
                                        search: self.currentSearchText) { [weak self] result in
            self?.loading = false
            switch result {
            case .success(let response):
                self?.hasMore = response.hasMore ?? false
                if from == .zero {
                    self?.reviews = response.results ?? []
                } else {
                    self?.reviews.append(contentsOf: response.results ?? [])
                }
                self?.originalReviews = self?.reviews ?? []
                self?.reloadWith?(.reloadCollection)
            case .failure(let error):
                self?.handleError(error: error)
            }
        }
    }
    
    func loadCritics(from: Int = 0) {
        self.networkClient.fetchCritics(from: from,
                                        search: self.currentSearchText) { [weak self] result in
            self?.loading = false
            switch result {
            case .success(let response):
                self?.hasMore = response.hasMore ?? false
                if from == .zero {
                    self?.critics = response.results ?? []
                } else {
                    self?.critics.append(contentsOf: response.results ?? [])
                }
                self?.reloadWith?(.reloadCollection)
            case .failure(let error):
                self?.handleError(error: error)
            }
        }
    }
    
    func searchChanged(text: String?) {
        self.currentSearchText = text
        self.reloadData()
    }
    
    func filterChanged(date: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-mm-dd"
        self.reviews = self.originalReviews.filter {
            guard let pubDate = dateFormatter.date(from: $0.publicationDate ?? "") else {
                return false
            }
            
            return pubDate >= date
        }
        self.reloadWith?(self.reviews.isEmpty ? .noResults : .reloadCollection)
    }
    
    func collectionCount() -> Int {
        return self.currentTab == .reviews ? self.reviews.count : self.critics.count
    }
    
    func shouldLoadNextPage(index: Int) {
        let count = self.collectionCount()
        guard self.hasMore,
              index + 2 > count,
              !self.loading else {
            return
        }
        
        self.loading = true
        switch self.currentTab {
        case .reviews:
            self.loadReviews(from: count)
        case .critics:
            self.loadCritics(from: count)
        }
    }
    
    func pullToRefresh() {
        self.reloadData()
    }
    
    // MARK: - Private methods
    
    private func handleError(error: NetworkError) {
        if case .error(let string) = error {
            self.reloadWith?(.error(string))
        }
    }
    
    private func reloadData() {
        if self.currentTab == .reviews {
            self.loadReviews()
        } else {
            self.loadCritics()
        }
    }

}
