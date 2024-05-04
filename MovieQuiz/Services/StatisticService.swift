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
        case correct, total, bestGame, gamesCount, totalQuestionCount, totalCorrectAnswersCount
    }
    
    var totalQuestionCount: Int {
        get {
            guard let data = userDefaults.data(forKey: Keys.totalQuestionCount.rawValue),
                  let total = try? JSONDecoder().decode(Int.self, from: data) else {
                return 0
            }
            return total
        }
        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                print("Невозможно сохранить результат")
                return
            }
            userDefaults.set(data, forKey: Keys.totalQuestionCount.rawValue)
        }
    }
    
    var totalCorrectAnswersCount: Int {
        get {
            guard let data = userDefaults.data(forKey: Keys.totalCorrectAnswersCount.rawValue),
                  let total = try? JSONDecoder().decode(Int.self, from: data) else {
                return 0
            }
            return total
        }
        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                print("Невозможно сохранить результат")
                return
            }
            userDefaults.setValue(data, forKey: Keys.totalCorrectAnswersCount.rawValue)
        }
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
        totalQuestionCount += amount
        totalCorrectAnswersCount += count
        gamesCount += 1
        totalAccuracy = Double(totalCorrectAnswersCount) / Double(totalQuestionCount)
    }
    
    func getGamesStatistic(correct count: Int, total amount: Int) -> String {
        return  """
                Ваш результат:\(count)/\(amount)\n
                Количество сыграных квизов: \(gamesCount)\n
                Рекорд: \(bestGame.correct) (\(bestGame.date.dateTimeString))\n
                Средняя точность: \(String(format: "%.2f", totalAccuracy * 100))%
                """
    }
}
