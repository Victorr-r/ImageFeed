import Foundation
import UIKit

final class ImagesListPresenter: ImagesListPresenterProtocol {
	
	// MARK: - Public Properties
	weak var view: ImagesListViewControllerProtocol?
	var photos: [Photo] = []
	
	// MARK: - Private Properties
	private let imagesListService = ImagesListService.shared
	private var imagesListServiceObserver: NSObjectProtocol?
	
	// MARK: - Initializer / Deinit
	deinit {
		if let observer = imagesListServiceObserver {
			NotificationCenter.default.removeObserver(observer)
		}
	}
	
	// MARK: - ImagesListPresenterProtocol
	func viewDidLoad() {
		setupObserver()
		fetchPhotosNextPage()
	}
	
	func fetchPhotosNextPage() {
		imagesListService.fetchPhotosNextPage()
	}
	
	func handleLike(for indexPath: IndexPath, completion: @escaping (Bool) -> Void) {
		let photo = photos[indexPath.row]
		
		view?.showLoading()
		
		imagesListService.changeLike(photoId: photo.id, isLike: !photo.isLiked) { [weak self] result in
			guard let self else { return }
			
			self.view?.hideLoading()
			
			switch result {
			case .success:
				self.photos = self.imagesListService.photos
				completion(self.photos[indexPath.row].isLiked)
			case .failure:
				self.view?.showLikeError()
			}
		}
	}
	
	func getCellHeight(for indexPath: IndexPath, tableViewWidth: CGFloat) -> CGFloat {
		let photo = photos[indexPath.row]
		let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
		let imageViewWidth = tableViewWidth - imageInsets.left - imageInsets.right
		let scale = imageViewWidth / photo.size.width
		return photo.size.height * scale + imageInsets.top + imageInsets.bottom
	}
	
	// MARK: - Private Methods
	
	private func setupObserver() {
		imagesListServiceObserver = NotificationCenter.default.addObserver(
			forName: ImagesListService.didChangeNotification,
			object: nil,
			queue: .main
		) { [weak self] _ in
			self?.updatePhotos()
		}
	}
	
	private func updatePhotos() {
		let oldCount = photos.count
		let newCount = imagesListService.photos.count
		photos = imagesListService.photos
		
		if oldCount < newCount {
			let indexPaths = (oldCount..<newCount).map { IndexPath(row: $0, section: 0) }
			view?.updateTableViewAnimated(with: indexPaths)
		}
	}
}
