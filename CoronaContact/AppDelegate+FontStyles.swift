//
//  FontStyles.swift
//  CoronaContact
//

import UIKit
import SwiftRichString
import Resolver

// swiftlint:disable identifier_name
enum StyleNames: String {
    case body
    case bodyCenter
    case bodySmall
    case bold
    case boldWhite
    case boldCenter
    case boldRed
    case boldYellow
    case boldBlue
    case underline
    case h1
    case h1b
    case h2
    case h2Center
    case tableHeader
    case tableData
    case tableDataRed
    case tableDataGreen
    case primaryButton
    case secondaryButton
}

enum ModifierNames: String {
    case truncatingMiddle

}

private struct FontSettings {
    struct Size {
        let h1: CGFloat
        let h2: CGFloat
        let body: CGFloat
        let bodyMedium: CGFloat
        let bodySmall: CGFloat
        let button: CGFloat
    }

    struct LineHeight {
        let h1: CGFloat
        let h2: CGFloat
        let body: CGFloat
        let bodyMedium: CGFloat
        let bodySmall: CGFloat
        let button: CGFloat
    }

    var size: Size
    var height: LineHeight

    func bodyFontStyle(weight: UIFont.Weight) -> Style {
        Style {
            $0.font = UIFont.systemFont(ofSize: self.size.body, weight: weight)
            $0.minimumLineHeight = self.height.body
            $0.maximumLineHeight = self.height.body
        }
    }

    func h1FontStyle(weight: UIFont.Weight) -> Style {
        Style {
            $0.font = UIFont.systemFont(ofSize: self.size.h1, weight: weight)
            $0.minimumLineHeight = self.height.h1
            $0.maximumLineHeight = self.height.h1
        }
    }

    func h2FontStyle(weight: UIFont.Weight) -> Style {
        Style {
            $0.font = UIFont.systemFont(ofSize: self.size.h2, weight: weight)
            $0.minimumLineHeight = self.height.h2
            $0.maximumLineHeight = self.height.h2
        }
    }
}

// swiftlint:enable identifier_name

extension AppDelegate {

    private func registerBoldStyles(settings: FontSettings) {
        let boldStyle = settings.bodyFontStyle(weight: .bold).byAdding {
            $0.color = UIColor.ccBlack
        }
        Styles.register(StyleNames.bold.rawValue, style: boldStyle)

        let boldWhiteStyle = settings.bodyFontStyle(weight: .bold).byAdding {
            $0.color = UIColor.white
        }
        Styles.register(StyleNames.boldWhite.rawValue, style: boldWhiteStyle)

        let boldCenterStyle = settings.bodyFontStyle(weight: .bold).byAdding {
            $0.color = UIColor.ccBlack
            $0.alignment = .center
        }
        Styles.register(StyleNames.boldCenter.rawValue, style: boldCenterStyle)

        let boldRedStyle = settings.bodyFontStyle(weight: .bold).byAdding {
            $0.color = UIColor.ccRouge
        }
        Styles.register(StyleNames.boldRed.rawValue, style: boldRedStyle)

        let boldYellowStyle = settings.bodyFontStyle(weight: .bold).byAdding {
            $0.color = UIColor.ccYellow
        }
        Styles.register(StyleNames.boldYellow.rawValue, style: boldYellowStyle)

        let boldBlueStyle = settings.bodyFontStyle(weight: .bold).byAdding {
            $0.color = UIColor.ccBlue
        }
        Styles.register(StyleNames.boldBlue.rawValue, style: boldBlueStyle)
    }

    private func registerBodyStyles(settings: FontSettings) {
        let bodyStyle = settings.bodyFontStyle(weight: .regular).byAdding {
            $0.color = UIColor.ccBlack
        }

        let underlineStyle = Style {
            $0.underline = (NSUnderlineStyle.single, nil)
        }

        Styles.register(StyleNames.body.rawValue,
                        style: StyleXML(base: bodyStyle, [
                            "b": Styles.getStyle(.bold),
                            "bred": Styles.getStyle(.boldRed),
                            "u": underlineStyle
                        ]))

        let bodyCenterStyle = settings.bodyFontStyle(weight: .regular).byAdding {
            $0.color = UIColor.ccBlack
            $0.alignment = .center
        }
        Styles.register(StyleNames.bodyCenter.rawValue, style: bodyCenterStyle)
    }

    private func registerBodySmallStyles(settings: FontSettings) {
        let bodySmallStyle = Style({
            $0.font = UIFont.systemFont(ofSize: settings.size.bodySmall, weight: .regular)
            $0.color = UIColor.ccBlack
            $0.minimumLineHeight = settings.height.body
            $0.maximumLineHeight = settings.height.body
        })

        Styles.register(StyleNames.bodySmall.rawValue, style: bodySmallStyle)
    }

    private func registerHeadlineStyles(settings: FontSettings) {
        let h1Style = settings.h1FontStyle(weight: .bold).byAdding {
            $0.color = UIColor.ccRouge
            $0.alignment = .center
        }
        Styles.register(StyleNames.h1.rawValue, style: h1Style)

        let h1bStyle = settings.h1FontStyle(weight: .bold).byAdding {
            $0.color = UIColor.ccBlack
            $0.alignment = .center
        }
        Styles.register(StyleNames.h1b.rawValue, style: h1bStyle)

        let h2Style = settings.h2FontStyle(weight: .bold).byAdding {
            $0.color = UIColor.ccBlack
            $0.alignment = .left
        }
        Styles.register(StyleNames.h2.rawValue, style: h2Style)

        let h2CenterStyle = settings.h2FontStyle(weight: .bold).byAdding {
            $0.color = UIColor.ccBlack
            $0.alignment = .center
        }
        Styles.register(StyleNames.h2Center.rawValue, style: h2CenterStyle)
    }

    private func registerModifiers() {
        let truncatingMiddleModifier = Style({
            $0.lineBreakMode = .byTruncatingMiddle
        })

        Styles.register(ModifierNames.truncatingMiddle.rawValue, style: truncatingMiddleModifier)
    }

    // swiftlint:disable function_body_length
    func registerFontStyles() {
        var settings = FontSettings(
            size: FontSettings.Size(
                h1: 24,
                h2: 20,
                body: 16,
                bodyMedium: 16,
                bodySmall: 16,
                button: 16
            ),
            height: FontSettings.LineHeight(
                h1: 32,
                h2: 24,
                body: 22,
                bodyMedium: 22,
                bodySmall: 22,
                button: 22
            )
        )

        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            switch appDelegate.screenSize {
            case .medium:
                settings.size = FontSettings.Size(
                    h1: 28,
                    h2: 20,
                    body: 18,
                    bodyMedium: 16,
                    bodySmall: 16,
                    button: 16
                )
                settings.height = FontSettings.LineHeight(
                    h1: 36,
                    h2: 24,
                    body: 24,
                    bodyMedium: 22,
                    bodySmall: 22,
                    button: 22
                )
            case .large:
                settings.size = FontSettings.Size(
                    h1: 32,
                    h2: 20,
                    body: 20,
                    bodyMedium: 18,
                    bodySmall: 16,
                    button: 18
                )
                settings.height = FontSettings.LineHeight(
                    h1: 40,
                    h2: 24,
                    body: 28,
                    bodyMedium: 24,
                    bodySmall: 22,
                    button: 24
                )
            default:
                ()
            }
        }

        registerBoldStyles(settings: settings)
        registerBodyStyles(settings: settings)
        registerBodySmallStyles(settings: settings)
        registerHeadlineStyles(settings: settings)
        registerModifiers()

        let primaryButtonStyle = Style({
            $0.font = UIFont.systemFont(ofSize: settings.size.button, weight: .bold)
            $0.color = UIColor.white
            $0.minimumLineHeight = settings.height.button
            $0.maximumLineHeight = settings.height.button
        })
        Styles.register(StyleNames.primaryButton.rawValue, style: primaryButtonStyle)

        let tableHeaderStyle = Style {
            $0.font = UIFont.systemFont(ofSize: settings.size.body - 1, weight: .semibold)
            $0.color = UIColor.white
        }
        Styles.register(StyleNames.tableHeader.rawValue, style: tableHeaderStyle)

        let tableDataStyle = Style {
            $0.font = UIFont.systemFont(ofSize: settings.size.body, weight: .semibold)
            $0.color = UIColor.ccBlack
        }
        Styles.register(StyleNames.tableData.rawValue, style: tableDataStyle)

        let tableDataRedStyle = Style {
            $0.font = UIFont.systemFont(ofSize: settings.size.body, weight: .semibold)
            $0.color = UIColor.ccRouge
        }
        Styles.register(StyleNames.tableDataRed.rawValue, style: tableDataRedStyle)

        let tableDataGreenStyle = Style {
            $0.font = UIFont.systemFont(ofSize: settings.size.body, weight: .semibold)
            $0.color = UIColor.ccGreen
        }
        Styles.register(StyleNames.tableDataGreen.rawValue, style: tableDataGreenStyle)

        Styles.register(StyleNames.tableData.rawValue,
        style: StyleXML(base: tableDataStyle, [
            "red": Styles.getStyle(.tableDataRed)
        ]))

        let secondaryButtonStyle = primaryButtonStyle.byAdding { $0.color = UIColor.ccRouge }
        Styles.register(StyleNames.secondaryButton.rawValue, style: secondaryButtonStyle)
    }
}

private extension StylesManager {
    func getStyle(_ name: StyleNames) -> StyleProtocol {
        let style = Styles.styles[name.rawValue]
        if style == nil { fatalError("unknown style! \(name)") }
        return style!
    }
}
