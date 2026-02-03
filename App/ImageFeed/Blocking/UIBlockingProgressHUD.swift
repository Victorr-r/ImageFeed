import UIKit

final class UIBlockingProgressHUD {
	private static var window: UIWindow? {
		UIApplication.shared.connectedScenes
			.compactMap { $0 as? UIWindowScene }
			.flatMap { $0.windows }
			.first { $0.isKeyWindow }
	}
	
	private static var indicator: UIActivityIndicatorView?
	
	static func show() {
		window?.isUserInteractionEnabled = false
		
		if indicator == nil {
			let activityIndicator = UIActivityIndicatorView(style: .large)
			activityIndicator.color = .systemGray // Используем системный цвет
			activityIndicator.center = window?.center ?? .zero
			indicator = activityIndicator
			window?.addSubview(activityIndicator)
		}
		indicator?.startAnimating()
	}
	
	static func dismiss() {
		window?.isUserInteractionEnabled = true
		indicator?.stopAnimating()
		indicator?.removeFromSuperview()
		indicator = nil
	}
}
