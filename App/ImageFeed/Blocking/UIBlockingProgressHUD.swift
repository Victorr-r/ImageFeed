import UIKit
import ProgressHUD

final class UIBlockingProgressHUD {
	private static var window: UIWindow? {
		return UIApplication.shared.connectedScenes
			.compactMap { $0 as? UIWindowScene }
			.flatMap { $0.windows }
			.first { $0.isKeyWindow }
	}
	
	private static var indicator: UIActivityIndicatorView?
	
	static func show() {
		window?.isUserInteractionEnabled = false
		ProgressHUD.animate()
	}
	
	static func dismiss() {
		window?.isUserInteractionEnabled = true
		ProgressHUD.dismiss()
	}
}
