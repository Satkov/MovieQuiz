import Foundation
import CoreGraphics

// MARK: Float Extension

public extension Float {

    static var random: Float {
        return Float(arc4random()) / Float(UInt32.max)
    }

    /// Random float between n + 1  and n-1.
    ///
    /// - Parameter rating:  Interval mid
    /// - Returns:      Returns a random float point number between n - 1 and n + 1
    static func randomRatingNumber(rating: Float) -> Float {
        let randomRatingNumber = Float.random * ((rating + 1) - (rating - 1)) + rating - 1
        switch randomRatingNumber {
        case _ where randomRatingNumber >= 10:
            return 9.9
        case rating:
            return randomRatingNumber - 0.1
        default:
            return randomRatingNumber
        }
    }
}
