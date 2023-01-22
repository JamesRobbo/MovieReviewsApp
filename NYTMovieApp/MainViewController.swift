import UIKit

enum Tab: Int {
    case reviews = 0
    case critics = 1
}

class MainViewController: BaseViewController<MainViewModel> {
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var filterContainerView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var refreshView: UIView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var filterLabel: UILabel!
    
    private var refreshControl = UIRefreshControl()
    private var fullscreenRefresh = UIActivityIndicatorView()
    
    let flowLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 5
        layout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        layout.sectionHeadersPinToVisibleBounds = true
        return layout
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupCollectionView()
        self.setupSegmentedControl()
        self.setupSearchBar()
        self.setupFilterBar()
        self.viewModel.loadReviews()
        self.title = "Reviews"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let isReview = self.viewModel.currentTab == .reviews
        self.setNavColour(colour: isReview ? .Palette.navOrange : .Palette.navBlue)
    }
    
    private func setNavColour(colour: UIColor?) {
        self.navigationController?.navigationBar.backgroundColor = colour
        self.view.backgroundColor = colour
    }
    
    private func setupFilterBar() {
        self.filterLabel.text = "Date from"
        self.datePicker.backgroundColor = .Palette.greyBackground
        self.filterContainerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(filterTapped)))
    }
    
    @objc func filterTapped() {
        self.datePicker.isHidden.toggle()
        if self.datePicker.isHidden {
            let date = self.datePicker.date
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy/MM/dd"
            self.filterLabel.text = dateFormatter.string(from: date)
            self.viewModel.filterChanged(date: date)
        }
    }
    
    private func setupSearchBar() {
        self.searchBar.layer.cornerRadius = 3
        self.searchBar.delegate = self
    }
    
    private func setupSegmentedControl() {
        self.segmentedControl.layer.cornerRadius = 5
        self.segmentedControl.backgroundColor = .clear
        self.segmentedControl.layer.shadowColor = .none
        self.segmentedControl.selectedSegmentTintColor = .white
        self.segmentedControl.layer.borderColor = UIColor.white.cgColor
        self.segmentedControl.layer.borderWidth = 1
        self.segmentedControl.layer.backgroundColor = UIColor.clear.cgColor
        self.segmentedControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
    }
    
    @objc private func segmentChanged() {
        guard let newTab = Tab(rawValue: self.segmentedControl.selectedSegmentIndex) else {
            return
        }
        
        self.datePicker.isHidden = true
        self.viewModel.currentTab = newTab
    }
    
    private func setupCollectionView() {
        let reviewNib = UINib(nibName: "ReviewsCollectionViewCell", bundle: nil)
        self.collectionView.register(reviewNib, forCellWithReuseIdentifier: "Review")
        let criticNib = UINib(nibName: "CriticsCollectionViewCell", bundle: nil)
        self.collectionView.register(criticNib, forCellWithReuseIdentifier: "Critic")
        self.refreshControl.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
        self.collectionView.refreshControl = self.refreshControl
        self.collectionView.collectionViewLayout = self.flowLayout
    }
    
    @objc func pullToRefresh() {
        self.viewModel.pullToRefresh()
    }
    
    override func reload(_ type: MainViewModel.ReloadType) {
        switch type {
        case .reloadCollection:
            self.collectionView.reloadData()
            self.refreshControl.endRefreshing()
            self.fullscreenRefresh.stopAnimating()
            self.fullscreenRefresh.removeFromSuperview()
            self.refreshView.isHidden = true
            self.collectionView.isHidden = false
        case .noResults:
            self.collectionView.reloadData()
            self.presentAlert(title: "No results")
        case .tabChange:
            self.collectionView.isHidden = true
            self.refreshView.isHidden = false
            self.refreshView.addSubview(self.fullscreenRefresh)
            self.fullscreenRefresh.pinToSuperviewBounds()
            self.fullscreenRefresh.startAnimating()
            let isReview = self.viewModel.currentTab == .reviews
            self.setNavColour(colour: isReview ? .Palette.navOrange : .Palette.navBlue)
            self.title = isReview ? "Reviews" : "Critics"
            self.filterContainerView.isHidden = !isReview
        case .error(let errorString):
            self.presentAlert(title: errorString)
        }
    }
    
    private func reload() {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    private func presentAlert(title: String) {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel))
        self.present(alert, animated: true)
    }
}

extension MainViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard self.viewModel.currentTab == .critics else {
            return
        }
        
        let viewModel = CriticViewModel(critic: self.viewModel.critics[indexPath.row])
        let viewController = CriticViewController(viewModel: viewModel)
        self.navigationController?.pushViewController(viewController, animated: false)
    }
}

extension MainViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel.collectionCount()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        self.viewModel.shouldLoadNextPage(index: indexPath.row)
        switch self.viewModel.currentTab {
        case .reviews:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Review", for: indexPath) as? ReviewsCollectionViewCell
            cell?.setup(review: self.viewModel.reviews[indexPath.row])
            return cell ?? UICollectionViewCell()
        case .critics:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Critic", for: indexPath) as? CriticsCollectionViewCell
            cell?.setup(critic: self.viewModel.critics[indexPath.row])
            return cell ?? UICollectionViewCell()
        }
    }
}

extension MainViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width
        let isReviews = self.viewModel.currentTab == .reviews
        let numberOfItemsPerRow: CGFloat = isReviews ? 1 : 2
        let spacing: CGFloat = self.flowLayout.minimumInteritemSpacing
        let availableWidth = width - spacing * (numberOfItemsPerRow + 1)
        let itemDimension = floor(availableWidth / numberOfItemsPerRow)
        return CGSize(width: itemDimension, height: 200)
    }
}

extension MainViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.viewModel.searchChanged(text: searchBar.text)
    }
}
