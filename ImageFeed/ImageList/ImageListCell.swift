import UIKit

final class ImagesListCell: UITableViewCell {
	
	// MARK: - Outlets
	
	@IBOutlet weak var cellImage: UIImageView!
	@IBOutlet weak var dateLabel: UILabel!
	@IBOutlet weak var likeButton: UIButton!
	
	// MARK: - Public Properties
	
	static let reuseIdentifier = "ImagesListCell"
}
