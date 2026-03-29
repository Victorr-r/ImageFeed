import UIKit
import Kingfisher

// MARK: - Protocols
protocol ImagesListViewControllerProtocol: AnyObject {
	func updateTableViewAnimated(with indexPaths: [IndexPath])
	func showLoading()
	func hideLoading()
	func showLikeError()
}

protocol ImagesListPresenterProtocol: AnyObject {
	var view: ImagesListViewControllerProtocol? { get set }
	var photos: [Photo] { get }
	func viewDidLoad()
	func fetchPhotosNextPage()
	func handleLike(for indexPath: IndexPath, completion: @escaping (Bool) -> Void)
	func getCellHeight(for indexPath: IndexPath, tableViewWidth: CGFloat) -> CGFloat
}

// MARK: - ImageListViewController
final class ImageListViewController: UIViewController, ImagesListViewControllerProtocol {
	
	// MARK: - Outlets
	
	@IBOutlet private weak var tableView: UITableView!
	
	// MARK: - Private Properties
	private var presenter: ImagesListPresenterProtocol?
	private let showSingleImageSegueIdentifier = "ShowSingleImage"
	private lazy var dateFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateStyle = .long
		formatter.timeStyle = .none
		return formatter
	}()
	
	
	
	// MARK: - Lifecycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		configureTableView()
		presenter?.viewDidLoad()
	}
	
	func configure(_ presenter: ImagesListPresenterProtocol) {
		self.presenter = presenter
		self.presenter?.view = self
	}
	
	// MARK: - ImagesListViewControllerProtocol
	
	func updateTableViewAnimated(with indexPaths: [IndexPath]) {
		tableView.performBatchUpdates {
			tableView.insertRows(at: indexPaths, with: .automatic)
		}
	}
	
	func showLoading() { UIBlockingProgressHUD.show() }
	func hideLoading() { UIBlockingProgressHUD.dismiss() }
	
	func showLikeError() {
		let alert = UIAlertController(title: "Ошибка", message: "Не удалось изменить состояние лайка", preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "Ок", style: .default))
		present(alert, animated: true)
	}
	
	// MARK: - Navigation
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == showSingleImageSegueIdentifier {
			guard let viewController = segue.destination as? SingleImageViewController,
				  let indexPath = sender as? IndexPath,
				  let photo = presenter?.photos[indexPath.row] else { return }
			
			viewController.fullImageURL = URL(string: photo.largeImageURL)
		}
	}
	
	private func configureTableView() {
		tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
	}
}

// MARK: - UITableViewDataSource
extension ImageListViewController: UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return presenter?.photos.count ?? 0
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
		guard let imageListCell = cell as? ImagesListCell else { return UITableViewCell() }
		
		imageListCell.delegate = self
		configCell(for: imageListCell, with: indexPath)
		return imageListCell
	}
}

// MARK: - Cell Configuration
extension ImageListViewController {
	func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
		guard let photo = presenter?.photos[indexPath.row],
			  let url = URL(string: photo.thumbImageURL) else { return }
		
		cell.cellImage.kf.indicatorType = .activity
		cell.cellImage.kf.setImage(with: url, placeholder: UIImage(named: "stub"))
		
		cell.dateLabel.text = photo.createdAt != nil ? dateFormatter.string(from: photo.createdAt!) : ""
		cell.setIsLiked(photo.isLiked)
	}
}

// MARK: - UITableViewDelegate
extension ImageListViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let storyboard = UIStoryboard(name: "Main", bundle: .main)
			guard let viewController = storyboard.instantiateViewController(
				withIdentifier: "SingleImageViewController"
			) as? SingleImageViewController else { return }
			
		let photo = ImagesListService.shared.photos[indexPath.row]
			guard let imageURL = URL(string: photo.largeImageURL) else { return }
			
			viewController.fullImageURL = imageURL
			
			viewController.modalPresentationStyle = .fullScreen
			present(viewController, animated: true)
		}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return presenter?.getCellHeight(for: indexPath, tableViewWidth: tableView.bounds.width) ?? 0
	}
	
	func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		if indexPath.row + 1 == presenter?.photos.count {
			presenter?.fetchPhotosNextPage()
		}
	}
}

// MARK: - ImagesListCellDelegate
extension ImageListViewController: ImagesListCellDelegate {
	func imageListCellDidTapLike(_ cell: ImagesListCell) {
		guard let indexPath = tableView.indexPath(for: cell) else { return }
		
		presenter?.handleLike(for: indexPath) { [weak cell] isLiked in
			cell?.setIsLiked(isLiked)
		}
	}
}

