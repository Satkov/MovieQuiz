import UIKit

enum LoadError: Error, LocalizedError {
    case failedLoadImage

    public var errorDescription: String? {
        switch self {
        case .failedLoadImage:
            return NSLocalizedString(
                "Failed load image",
                comment: "Resource Not Found.")
        }
    }
}
