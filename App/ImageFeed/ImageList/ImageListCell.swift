import UIKit
import Kingfisher

protocol ImagesListCellDelegate: AnyObject {
	func imageListCellDidTapLike(_ cell: ImagesListCell)
}

final class ImagesListCell: UITableViewCell {
	
	// MARK: - Private Properties
	private enum LikeButtons {
		static let likeButtonOn = "like_button_on"
		static let likeButtonOff = "like_button_off"
	}
	
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
		let imageName = isLiked ? LikeButtons.likeButtonOn : LikeButtons.likeButtonOff
		let likeImage = UIImage(named: imageName)
		
		likeButton.setImage(likeImage, for: .normal)
		likeButton.accessibilityIdentifier = isLiked ? "like button on" : "like button off"
	}
	
	// MARK: -  Overrides
	
	override func awakeFromNib() {
		super.awakeFromNib()
		selectionStyle = .none
	}
	
	override func prepareForReuse() {
		super.prepareForReuse()
		
		cellImage.kf.cancelDownloadTask()
		cellImage.image = nil
	}
}
