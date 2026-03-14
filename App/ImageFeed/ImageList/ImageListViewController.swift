import UIKit
import Kingfisher

final class ImageListViewController: UIViewController {
	
	// MARK: - Outlets
	
	@IBOutlet private weak var tableView: UITableView!
	
	// MARK: - Private Properties
	private let showSingleImageSegueIdentifier = "ShowSingleImage"
	private let imagesListService = ImagesListService.shared
	private var photos: [Photo] = []
	private var imagesListServiceObserver: NSObjectProtocol?
	private lazy var dateFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateStyle = .long
		formatter.timeStyle = .none
		return formatter
	}()
	
	// MARK: - Lifecycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
		
		imagesListServiceObserver = NotificationCenter.default
			.addObserver(
				forName: ImagesListService.didChangeNotification,
				object: nil,
				queue: .main
			) { [weak self] _ in
				guard let self = self else { return }
				self.updateTableViewAnimated()
			}
		
		if imagesListService.photos.isEmpty {
			imagesListService.fetchPhotosNextPage()
		}
	}
	
	deinit {
		if let observer = imagesListServiceObserver {
			NotificationCenter.default.removeObserver(observer)
		}
	}
	
	func updateTableViewAnimated() {
		let oldCount = photos.count
		let newCount = imagesListService.photos.count
		
		photos = imagesListService.photos
		
		if oldCount < newCount {
			let indexPaths = (oldCount..<newCount).map { i in
				IndexPath(row: i, section: 0)
			}
			tableView.performBatchUpdates {
				tableView.insertRows(at: indexPaths, with: .automatic)
			} completion: { _ in }
		}
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == showSingleImageSegueIdentifier {
			guard
				let viewController = segue.destination as? SingleImageViewController,
				let indexPath = sender as? IndexPath
			else {
				assertionFailure("Invalid segue destination")
				return
			}
			
			let photo = photos[indexPath.row]
			viewController.fullImageURL = URL(string: photo.largeImageURL)
		} else {
			super.prepare(for: segue, sender: sender)
		}
	}
}

// MARK: - UITableViewDataSource
extension ImageListViewController: UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return photos.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
		
		guard let imageListCell = cell as? ImagesListCell else {
			return UITableViewCell()
		}
		imageListCell.delegate = self
		configCell(for: imageListCell, with: indexPath)
		return imageListCell
	}
}

// MARK: - Cell Configuration
extension ImageListViewController {
	func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
		let photo = photos[indexPath.row]
		guard let url = URL(string: photo.thumbImageURL) else { return }
		
		cell.cellImage.kf.cancelDownloadTask()
		
		let placeholder = UIImage(named: "stub")
		let processor = DownsamplingImageProcessor(size: cell.cellImage.bounds.size)
		
		cell.cellImage.kf.indicatorType = .activity
		cell.cellImage.kf.setImage(with: url, placeholder: placeholder, options: [.processor(processor)], completionHandler: nil)
		
		if let date = photo.createdAt {
			cell.dateLabel.text = dateFormatter.string(from: date)
		} else {
			cell.dateLabel.text = ""
		}
		
		let likeImage = photo.isLiked ? UIImage(named: "like_button_on") : UIImage(named: "like_button_off")
		cell.likeButton.setImage(likeImage, for: .normal)
	}
}

// MARK: - UITableViewDelegate
extension ImageListViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		let photo = photos[indexPath.row]
		
		let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
		let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
		let imageWidth = photo.size.width
		let scale = imageViewWidth / imageWidth
		let cellHeight = photo.size.height * scale + imageInsets.top + imageInsets.bottom
		return cellHeight
	}
	
	func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		if indexPath.row + 1 == photos.count {
			imagesListService.fetchPhotosNextPage()
		}
	}
}

// MARK: - ImagesListCellDelegate

extension ImageListViewController: ImagesListCellDelegate {
	func imageListCellDidTapLike(_ cell: ImagesListCell) {
		guard let indexPath = tableView.indexPath(for: cell) else { return }
		let photo = photos[indexPath.row]
		
		UIBlockingProgressHUD.show()
		
		imagesListService.changeLike(photoId: photo.id, isLike: !photo.isLiked) { [weak self] result in
			guard let self else { return }
			
			switch result {
			case .success:
				self.photos = self.imagesListService.photos
				
				cell.setIsLiked(self.photos[indexPath.row].isLiked)
				
				UIBlockingProgressHUD.dismiss()
				
			case .failure(let error):
				UIBlockingProgressHUD.dismiss()
				print("Error updating like: \(error.localizedDescription)")
				
				self.showLikeErrorAlert()
			}
		}
	}
	
	private func showLikeErrorAlert() {
		let alert = UIAlertController(
			title: "Ошибка",
			message: "Не удалось изменить состояние лайка",
			preferredStyle: .alert
		)
		alert.addAction(UIAlertAction(title: "Ок", style: .default))
		present(alert, animated: true)
	}
}
