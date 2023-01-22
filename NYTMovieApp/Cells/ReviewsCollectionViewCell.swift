import UIKit

class ReviewsCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var criticNameLabel: UILabel!
    @IBOutlet weak var movieNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    func setup(review: Review) {
        self.imageView.layer.cornerRadius = 5
        self.movieNameLabel.text = review.displayTitle
        self.descriptionLabel.text = review.summaryShort
        self.criticNameLabel.text = review.byline
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        if let date = dateFormatter.date(from: review.dateUpdated ?? "") {
            dateFormatter.dateFormat = "dd/MM/yyyy HH:mm:ss"
            let finalDate = dateFormatter.string(from: date)
            self.dateLabel.text = finalDate
        }
        self.imageView.load(url: review.multimedia?.src)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.imageView.image = nil
        self.descriptionLabel.text = nil
        self.criticNameLabel.text = nil
        self.movieNameLabel.text = nil
        self.dateLabel.text = nil
    }
}

