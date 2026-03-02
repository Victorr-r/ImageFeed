import UIKit

final class SingleImageViewController : UIViewController {
	
	// MARK: - Properties
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
	
	@IBOutlet weak var imageView: UIImageView!
	
	// MARK: - Lifecycle
	override func viewDidLoad() {
		super.viewDidLoad()
		scrollView.delegate = self
		scrollView.minimumZoomScale = 0.1
		scrollView.maximumZoomScale = 1.25
		guard let image else { return }
		imageView.image = image
		imageView.frame.size = image.size
		rescaleAndCenterImageInScrollView(image: image)
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
