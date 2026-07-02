import CoreGraphics

enum FilterMode: String, CaseIterable, Codable {
    case day
    case evening
    case night
    case custom

    var title: String {
        switch self {
        case .day: return "Día"
        case .evening: return "Tarde"
        case .night: return "Noche"
        case .custom: return "Personalizado"
        }
    }

    var preset: FilterPreset {
        switch self {
        case .day: return FilterPreset(warmth: 0.0, brightness: 1.0)
        case .evening: return FilterPreset(warmth: 0.45, brightness: 0.8)
        case .night: return FilterPreset(warmth: 0.9, brightness: 0.5)
        case .custom: return FilterPreset(warmth: 0.35, brightness: 0.9)
        }
    }
}

struct FilterPreset {
    let warmth: CGFloat
    let brightness: CGFloat
}
