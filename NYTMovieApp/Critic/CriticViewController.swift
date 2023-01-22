//
//  CriticViewController.swift
//  NYTMovieApp
//
//  Created by James Robinson on 29/01/2023.
//

import UIKit

class CriticViewController: BaseViewController<CriticViewModel> {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    let flowLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 5
        layout.sectionInset = UIEdgeInsets(top: 10 , left: 10, bottom: 10, right: 10)
        layout.sectionHeadersPinToVisibleBounds = true
        return layout
    }()
    
    override func viewDidLoad() {
        self.navigationController?.navigationBar.backgroundColor = .Palette.navBlue
        self.view.backgroundColor = .Palette.navBlue
        self.title = self.viewModel.critic.displayName
        super.viewDidLoad()
        self.setupCollectionView()
        self.viewModel.setup()
    }
    
    private func setupCollectionView() {
        let nib = UINib(nibName: "ReviewsCollectionViewCell", bundle: nil)
        self.collectionView.register(nib, forCellWithReuseIdentifier: "Review")
        let summaryNib = UINib(nibName: "CriticSummaryCollectionViewCell", bundle: nil)
        self.collectionView.register(summaryNib, forCellWithReuseIdentifier: "Summary")
        self.collectionView.collectionViewLayout = self.flowLayout
    }
    
    override func reload(_ type: CriticViewModel.ReloadType) {
        switch type {
        case .reloadCollection:
            self.collectionView.reloadData()
        case .error(let errorString):
            self.presentAlert(title: errorString)
        }
    }
    
    private func presentAlert(title: String) {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel))
        self.present(alert, animated: true)
    }
}

extension CriticViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return section == 1 ? self.viewModel.reviews.count : 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard indexPath.section == 1 else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Summary", for: indexPath) as? CriticSummaryCollectionViewCell
            cell?.setup(critic: self.viewModel.critic)
            return cell ?? UICollectionViewCell()
        }
        
        self.viewModel.shouldLoadNextPage(index: indexPath.row)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Review", for: indexPath) as? ReviewsCollectionViewCell
        if let cell = cell {
            cell.setup(review: self.viewModel.reviews[indexPath.row])
        }
        return cell ?? UICollectionViewCell()
    }
}

extension CriticViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width
        let numberOfItemsPerRow: CGFloat = 1
        let spacing: CGFloat = self.flowLayout.minimumInteritemSpacing
        let availableWidth = width - spacing * (numberOfItemsPerRow + 1)
        let itemDimension = floor(availableWidth / numberOfItemsPerRow)
        let height: CGFloat = indexPath.section == 1 ? 200 : 400
        return CGSize(width: itemDimension, height: height)
    }
}
