import UIKit

class CriticsCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    func setup(critic: Critic) {
        self.imageView.layer.cornerRadius = 5
        self.imageView.load(url: critic.multimedia?.resource?.src)
        self.nameLabel.text = critic.displayName
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.imageView.image = nil
        self.nameLabel.text = nil
    }
}
