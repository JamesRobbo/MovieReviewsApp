//
//  CriticSummaryCollectionViewCell.swift
//  NYTMovieApp
//
//  Created by James Robinson on 31/01/2023.
//

import UIKit

class CriticSummaryCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var bioLabel: UILabel!
    @IBOutlet weak var workTimeLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    func setup(critic: Critic) {
        self.imageView.load(url: critic.multimedia?.resource?.src)
        self.bioLabel.text = critic.bio
        self.workTimeLabel.text = critic.status?.rawValue
        self.nameLabel.text = critic.displayName
    }
}
