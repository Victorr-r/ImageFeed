import UIKit
import Kingfisher

protocol ImagesListCellDelegate: AnyObject {
	func imageListCellDidTapLike(_ cell: ImagesListCell)
}

final class ImagesListCell: UITableViewCell {
	
	// MARK: - Public Properties
	
	static let reuseIdentifier = "ImagesListCell"
	weak var delegate: ImagesListCellDelegate?
	// MARK: - Outlets
	
	@IBOutlet weak var cellImage: UIImageView!
	@IBOutlet weak var dateLabel: UILabel!
	@IBOutlet weak var likeButton: UIButton!
	@IBAction private func likeButtonClicked() {
		delegate?.imageListCellDidTapLike(self)
	}
	
	// MARK: - Public Methods
	func setIsLiked(_ isLiked: Bool) {
		let likeImage = isLiked ? UIImage(named: "like_button_on") : UIImage(named: "like_button_off")
		likeButton.setImage(likeImage, for: .normal)
	}
	
	// MARK: -  Overrides
	
	override func prepareForReuse() {
		super.prepareForReuse()
		
		cellImage.kf.cancelDownloadTask()
		cellImage.image = nil
	}
}
