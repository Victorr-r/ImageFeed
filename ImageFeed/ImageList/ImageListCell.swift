import UIKit

final class ImagesListCell: UITableViewCell {
	
	// MARK: - Outlets
	@IBOutlet var cellImage: UIImageView!
	@IBOutlet var dateLabel: UILabel!
	@IBOutlet var likeButton: UIButton!
	
	// MARK: - Public Properties
	static let reuseIdentifier = "ImagesListCell"
}
