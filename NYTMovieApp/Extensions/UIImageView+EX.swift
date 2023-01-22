import UIKit

extension UIImageView {
    func load(url: String?) {
        guard let urlString = url,
              let URL = URL(string: urlString) else {
            self.image = UIImage(systemName: "photo")
            return
        }
        
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: URL) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}
