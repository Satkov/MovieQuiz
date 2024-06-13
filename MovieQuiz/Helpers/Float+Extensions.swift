import Foundation
import CoreGraphics

// MARK: Float Extension

public extension Float {

    /// Returns a random floating point number between 0.0 and 1.0, inclusive.
    static var random: Float {
        return Float(arc4random()) / Float(UInt32.max)
    }

    /// Random float between 0 and n-1.
    ///
    /// - Parameter n:  Interval max
    /// - Returns:      Returns a random float point number between 0 and n max
    static func randomRatingNumber(rating: Float) -> Float {
        var randomRatingNumber = Float.random * ((rating + 1) - (rating - 1)) + rating - 1
        if randomRatingNumber >= 10 {
            randomRatingNumber = 9.9
        }
        if randomRatingNumber == rating{
            randomRatingNumber -= 0.1
        }
        return randomRatingNumber
    }
}
