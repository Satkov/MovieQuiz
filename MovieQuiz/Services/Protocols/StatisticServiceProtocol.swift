import Foundation

protocol StatisticServiceProtocol {
    var totalAccuracy: Double { get }
    var gamesCount: Int { get }
    var bestGame: GameRecord { get }
    var totalQuestionCount: Int { get }
    var totalCorrectAnswersCount: Int { get }
    func store(correct count: Int, total amount: Int)
    func getGamesStatistic(correct count: Int, total amount: Int) -> String
}
