import Foundation

struct Level: Codable {
    var currentLevel: Int
    var currentXP: Int
    var xpForNextLevel: Int
    
    var progress: Double {
        return Double(currentXP % xpForNextLevel) / Double(xpForNextLevel)
    }
    
    static func calculateLevel(from xp: Int) -> Int {
        // Base XP per level: 1000
        return (xp / 1000) + 1
    }
    
    static func xpForNextLevel(level: Int) -> Int {
        return 1000 // Constant for now, or could be level * 1000
    }
}
