import SwiftUI

struct HeartCustomizationView: View {
    @StateObject private var customizationManager = HeartCustomizationManager()
    @StateObject private var levelingManager = LevelingManager.shared
    @State private var selectedTab: CustomizationTab = .colors
    @State private var previewCustomization = HeartCustomization.default
    
    enum CustomizationTab: String, CaseIterable {
        case colors = "Colors"
        case accessories = "Accessories"
        case expressions = "Expressions"
        
        var icon: String {
            switch self {
            case .colors: return "paintpalette.fill"
            case .accessories: return "crown.fill"
            case .expressions: return "face.smiling.fill"
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Preview section
                VStack(spacing: 16) {
                    Text("Your Heart")
                        .font(.title2.weight(.semibold))
                        .foregroundColor(.primary)
                    
                    // Live preview
                    HeartCharacter(
                        size: 120,
                        primaryColor: colorFromString(previewCustomization.primaryColor),
                        secondaryColor: colorFromString(previewCustomization.secondaryColor),
                        isAnimating: true,
                        accessory: previewCustomization.accessory,
                        expression: previewCustomization.expression
                    )
                    
                    Text("Level \(levelingManager.currentLevel)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(.ultraThinMaterial, in: Capsule())
                }
                .padding(.vertical, 24)
                .background(.ultraThinMaterial)
                
                // Customization tabs
                Picker("Customization", selection: $selectedTab) {
                    ForEach(CustomizationTab.allCases, id: \.self) { tab in
                        Label(tab.rawValue, systemImage: tab.icon)
                            .tag(tab)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                
                // Content
                ScrollView {
                    switch selectedTab {
                    case .colors:
                        ColorCustomizationView(customization: $previewCustomization)
                    case .accessories:
                        AccessoryCustomizationView(customization: $previewCustomization)
                    case .expressions:
                        ExpressionCustomizationView(customization: $previewCustomization)
                    }
                }
            }
            .navigationTitle("Customize Heart")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        customizationManager.updateUserCustomization(previewCustomization)
                    }
                    .font(.body.weight(.medium))
                }
            }
        }
        .onAppear {
            previewCustomization = customizationManager.userCustomization
        }
    }
    
    private func colorFromString(_ colorString: String) -> Color {
        switch colorString {
        case "crimson": return ColorPalette.crimson
        case "roseGold": return ColorPalette.roseGold
        case "amber": return ColorPalette.amber
        case "deepPurple": return ColorPalette.deepPurple
        default: return ColorPalette.crimson
        }
    }
}

struct ColorCustomizationView: View {
    @Binding var customization: HeartCustomization
    @StateObject private var levelingManager = LevelingManager.shared
    
    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            ForEach(HeartColorTheme.allCases, id: \.self) { theme in
                ColorThemeCard(
                    theme: theme,
                    isSelected: customization.primaryColor == theme.rawValue,
                    isUnlocked: levelingManager.currentLevel >= theme.unlockLevel
                ) {
                    if levelingManager.currentLevel >= theme.unlockLevel {
                        customization.primaryColor = theme.rawValue
                        customization.secondaryColor = theme.rawValue + "_secondary"
                    }
                }
            }
        }
        .padding()
    }
}

struct ColorThemeCard: View {
    let theme: HeartColorTheme
    let isSelected: Bool
    let isUnlocked: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                // Color preview
                HStack(spacing: 4) {
                    Circle()
                        .fill(theme.primaryColor)
                        .frame(width: 20, height: 20)
                    
                    Circle()
                        .fill(theme.secondaryColor)
                        .frame(width: 20, height: 20)
                }
                
                Text(theme.displayName)
                    .font(.caption.weight(.medium))
                    .foregroundColor(isUnlocked ? .primary : .secondary)
                
                if !isUnlocked {
                    Text("Level \(theme.unlockLevel)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(.ultraThinMaterial, in: Capsule())
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? theme.primaryColor.opacity(0.2) : .ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? theme.primaryColor : Color.clear, lineWidth: 2)
                    )
            )
            .opacity(isUnlocked ? 1.0 : 0.6)
        }
        .disabled(!isUnlocked)
    }
}

struct AccessoryCustomizationView: View {
    @Binding var customization: HeartCustomization
    @StateObject private var levelingManager = LevelingManager.shared
    
    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            ForEach(HeartAccessory.allCases, id: \.self) { accessory in
                AccessoryCard(
                    accessory: accessory,
                    isSelected: customization.accessory == accessory,
                    isUnlocked: levelingManager.currentLevel >= accessory.unlockLevel
                ) {
                    if levelingManager.currentLevel >= accessory.unlockLevel {
                        customization.accessory = accessory
                    }
                }
            }
        }
        .padding()
    }
}

struct AccessoryCard: View {
    let accessory: HeartAccessory
    let isSelected: Bool
    let isUnlocked: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                Image(systemName: accessory.icon)
                    .font(.title2)
                    .foregroundColor(isSelected ? ColorPalette.amber : .primary)
                
                Text(accessory.displayName)
                    .font(.caption.weight(.medium))
                    .foregroundColor(isUnlocked ? .primary : .secondary)
                    .multilineTextAlignment(.center)
                
                if !isUnlocked {
                    Text("Lv \(accessory.unlockLevel)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(.ultraThinMaterial, in: Capsule())
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? ColorPalette.amber.opacity(0.2) : .ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? ColorPalette.amber : Color.clear, lineWidth: 2)
                    )
            )
            .opacity(isUnlocked ? 1.0 : 0.6)
        }
        .disabled(!isUnlocked)
    }
}

struct ExpressionCustomizationView: View {
    @Binding var customization: HeartCustomization
    
    private let expressions: [(HeartExpression, String, String)] = [
        (.happy, "Happy", "face.smiling.fill"),
        (.focused, "Focused", "face.dashed.fill"),
        (.sleepy, "Sleepy", "moon.fill")
    ]
    
    var body: some View {
        VStack(spacing: 16) {
            ForEach(expressions, id: \.0) { expression, name, icon in
                Button(action: {
                    customization.expression = expression
                }) {
                    HStack(spacing: 16) {
                        Image(systemName: icon)
                            .font(.title2)
                            .foregroundColor(customization.expression == expression ? ColorPalette.amber : .primary)
                            .frame(width: 32)
                        
                        Text(name)
                            .font(.body.weight(.medium))
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        if customization.expression == expression {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(ColorPalette.amber)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(customization.expression == expression ? 
                                  ColorPalette.amber.opacity(0.1) : .ultraThinMaterial)
                    )
                }
            }
        }
        .padding()
    }
}