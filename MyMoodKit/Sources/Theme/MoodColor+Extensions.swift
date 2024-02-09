
import SwiftUI
import Models

// MARK: Color Extension

// Simplify initializing of Color with enum
extension Color {
    public init(_ color: MoodColor) {
        self.init(color.rawValue, bundle: .module)
    }
}

extension Color {
    public var rgba: Color.Resolved {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        let uiColor = UIColor(self)
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        return Color.Resolved(red: Float(red), green: Float(green), blue: Float(blue), opacity: Float(alpha))
    }
}

// MARK: Shape Extension

/// Use this modifier to fill in a Shape with a ShapeStyle that could be a MoodColor,
/// and add a stroke border around that Shape, with a ShapeStyle that could be a MoodColor
/// Sample Usage:
/// Circle()
///     .fill(.moodYellow, strokeBorder: .moodGreen, lineWidth: 10.0)
///
/// Reference:
/// https://www.hackingwithswift.com/quick-start/swiftui/how-to-fill-and-stroke-shapes-at-the-same-time
extension Shape {
    public func fill<Fill: ShapeStyle,
                     Stroke: ShapeStyle>
    (_ fillStyle: Fill, strokeBorder strokeStyle: Stroke, lineWidth: Double = 1) -> some View {
        self
            .stroke(strokeStyle, lineWidth: lineWidth)
            .background(self.fill(fillStyle))
    }
}

// MARK: InsettableShape Extension
/// Use this modifier to fill in an InsettableShape with a ShapeStyle that could be a MoodColor,
/// and add a stroke border around that InsettableShape, with a ShapeStyle that could be a MoodColor
/// Sample Usage:
/// Circle().inset(by: 20.0)    // create an Insettable Circle
///     .fill(.moodYellow, strokeBorder: .moodGreen, lineWidth: 10.0)
///
/// Reference:
/// https://www.hackingwithswift.com/quick-start/swiftui/how-to-fill-and-stroke-shapes-at-the-same-time
extension InsettableShape {
    func fill<Fill: ShapeStyle, Stroke: ShapeStyle>(_ fillStyle: Fill, strokeBorder strokeStyle: Stroke, lineWidth: Double = 1) -> some View {
        self
            .strokeBorder(strokeStyle, lineWidth: lineWidth)
            .background(self.fill(fillStyle))
    }
}


// MARK: ShapeStyle Extension

/// Extend ShapeStyle so that View Modifiers that take a ShapeStyle,
/// can take a ShapeStyle that is a custom SunfishColor
///
/// Sample Usage with the background View Modifier:
/// Text("Hello, World!")
///    .background(.moodRed)
///
/// Sample Usage with the foregroundColor View Modifier:
/// Text("Hello, World!")
///    .foregroundColor(.moodYellow)
///
/// Sample Usage with the fill View Modifier, to fill in a Shape,
/// with a ShapeStyle that is a SunfishColor:
/// Rectangle()
///     .fill(.moodYellow)
///
/// Sample Usage with the stroke View Modifier, to add a stroke border around a Shape,
/// with a ShapeStyle that is a SunfishColor:
/// Ellipse()
///     .stroke(.moodGreen, lineWidth: 5.0)
extension ShapeStyle where Self == Color {
    public static var moodRed: Color {
        Color(MoodColor.moodVariationRed)
    }
    
    public static var moodYellow: Color {
        Color(MoodColor.moodVariationYellow)
    }
    
    public static var moodGreen: Color {
        Color(MoodColor.moodVariationGreen)
    }
    
    public static var tabBar: Color {
        Color(MoodColor.tabBar)
        //Color(red: 0.74, green: 0.74, blue: 0.74)
    }
    
    public static var backgroundActionButton: Color {
        Color(MoodColor.actionButtonPrimary)
    }
    
    public static var borderActionButton: Color {
        Color(MoodColor.actionButtonSecondary)
    }
}
