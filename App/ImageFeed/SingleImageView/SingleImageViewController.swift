import UIKit
import Kingfisher

final class SingleImageViewController : UIViewController {
	
	// MARK: - Properties
	var fullImageURL: URL?
	var image: UIImage? {
		didSet {
			guard isViewLoaded, let image = image else { return }
			imageView.image = image
			imageView.frame.size = image.size
			rescaleAndCenterImageInScrollView(image: image)
		}
	}
	
	// MARK: - Outlets
	@IBOutlet private var scrollView: UIScrollView!
	
	@IBOutlet private weak var imageView: UIImageView!
	
	// MARK: - Lifecycle
	override func viewDidLoad() {
		super.viewDidLoad()
		scrollView.delegate = self
		scrollView.minimumZoomScale = 0.1
		scrollView.maximumZoomScale = 1.25
		if fullImageURL != nil {
			downloadImage()
		}
		else if let image = image {
			imageView.image = image
			imageView.frame.size = image.size
			rescaleAndCenterImageInScrollView(image: image)
		}
	}
	
	// MARK: - Actions
	@IBAction private func didTapBackButton() {
		dismiss(animated: true, completion: nil)
	}
	
	@IBAction private func didTapShareButton(_ sender: UIButton) {
		guard let image else { return }
		
		let shareController = UIActivityViewController(
			activityItems: [image],
			applicationActivities: nil
		)
		
		present(shareController, animated: true, completion: nil)
	}
	
	// MARK: - Private Methods
	private func rescaleAndCenterImageInScrollView(image: UIImage) {
		let minZoomScale = scrollView.minimumZoomScale
		let maxZoomScale = scrollView.maximumZoomScale
		view.layoutIfNeeded()
		let visibleRectSize = scrollView.bounds.size
		let imageSize = image.size
		let hScale = visibleRectSize.width / imageSize.width
		let vScale = visibleRectSize.height / imageSize.height
		let scale = min(maxZoomScale, max(minZoomScale, min(hScale, vScale)))
		scrollView.setZoomScale(scale, animated: false)
		scrollView.layoutIfNeeded()
		let newContentSize = scrollView.contentSize
		let x = (newContentSize.width - visibleRectSize.width) / 2
		let y = (newContentSize.height - visibleRectSize.height) / 2
		scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
	}
	
	private func downloadImage() {
		guard let fullImageURL = fullImageURL else { return }
		
		UIBlockingProgressHUD.show()
		
		imageView.kf.setImage(with: fullImageURL) { [weak self] result in
			UIBlockingProgressHUD.dismiss()
			
			guard let self else { return }
			
			switch result {
			case .success(let imageResult):
				self.image = imageResult.image
			case .failure:
				self.showError()
			}
		}
	}
	
	private func showError() {
		let alert = UIAlertController(
			title: "Что-то пошло не так",
			message: "Попробовать ещё раз?",
			preferredStyle: .alert
		)
		
		alert.addAction(UIAlertAction(title: "Не надо", style: .cancel))
		
		alert.addAction(UIAlertAction(title: "Повторить", style: .default) { [weak self] _ in
			self?.downloadImage()
		})
		
		present(alert, animated: true)
	}
}

// MARK: - UIScrollViewDelegate
extension SingleImageViewController: UIScrollViewDelegate {
	func viewForZooming(in scrollView: UIScrollView) -> UIView? {
		return imageView
	}
	func scrollViewDidZoom(_ scrollView: UIScrollView) {
		let offsetX = max((scrollView.bounds.width - scrollView.contentSize.width) * 0.5, 0)
		let offsetY = max((scrollView.bounds.height - scrollView.contentSize.height) * 0.5, 0)
		scrollView.contentInset = UIEdgeInsets(top: offsetY, left: offsetX, bottom: 0, right: 0)
	}
}
