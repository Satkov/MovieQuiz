import Foundation

struct GameRecord: Codable {
    let correct: Int
    let total: Int
    let date: Date

    func isBetterThan (_ another: GameRecord) -> Bool {
        correct > another.correct
    }
}

class StatisticServiceImplementation: StatisticServiceProtocol {
    private let userDefaults = UserDefaults.standard

    private enum Keys: String {
        case correct, total, bestGame, gamesCount
    }

    var totalAccuracy: Double {
        get {
            guard let data = userDefaults.data(forKey: Keys.total.rawValue),
                  let total = try? JSONDecoder().decode(Double.self, from: data) else {
                return 0
            }
            return total
        }
        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                print("Невозможно сохранить результат")
                return
            }
            userDefaults.set(data, forKey: Keys.total.rawValue)
        }
    }

    var gamesCount: Int {
        get {
            guard let data = userDefaults.data(forKey: Keys.gamesCount.rawValue),
                  let gamesCount = try? JSONDecoder().decode(Int.self, from: data) else {
                return 0
            }
            return gamesCount
        }
        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                print("Невозможно сохранить результат")
                return
            }
            userDefaults.set(data, forKey: Keys.gamesCount.rawValue)
        }
    }

    var bestGame: GameRecord {
        get {
            guard let data = userDefaults.data(forKey: Keys.bestGame.rawValue),
                  let record = try? JSONDecoder().decode(GameRecord.self, from: data) else {
                return .init(correct: 0, total: 0, date: Date())
            }
            return record
        }
        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                print("Невозможно сохранить результат")
                return
            }
            userDefaults.set(data, forKey: Keys.bestGame.rawValue)
        }
    }

    func store(correct count: Int, total amount: Int) {
        let newGame = GameRecord(correct: count, total: amount, date: Date())
        if newGame.isBetterThan(bestGame) {
            bestGame = newGame
        }
        let newGameAccuracy = Double(count) / Double(amount)
        totalAccuracy = (totalAccuracy * Double(gamesCount) + newGameAccuracy) / (Double(gamesCount) + 1)
        gamesCount += 1
    }

    func getGamesStatistic(correct count: Int, total amount: Int) -> String {
        let score = "Ваш результат: \(count)/\(amount)"
        let gameCount = "Количество сыграных квизов: \(gamesCount)"
        let record = "Рекорд: \(bestGame.correct)/\(bestGame.total) (\(bestGame.date.dateTimeString))"
        let averageAccuracy = "Средняя точность: \(String(format: "%.2f", totalAccuracy * 100))%"
        return  [score, gameCount, record, averageAccuracy].joined(separator: "\n")
    }
}
