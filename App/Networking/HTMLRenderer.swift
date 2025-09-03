import Foundation
import SwiftUI

enum HTMLRenderer {
    static func attributedString(from html: String) -> AttributedString {
        guard let data = html.data(using: .utf8) else { return AttributedString(html) }
        do {
            let attributed = try NSAttributedString(
                data: data,
                options: [
                    .documentType: NSAttributedString.DocumentType.html,
                    .characterEncoding: String.Encoding.utf8.rawValue
                ],
                documentAttributes: nil
            )
            // Normalize colors so dark mode doesn't produce dark-on-dark text.
            let mutable = NSMutableAttributedString(attributedString: attributed)
            let fullRange = NSRange(location: 0, length: mutable.length)
            mutable.enumerateAttributes(in: fullRange, options: []) { attrs, range, _ in
                var attrs = attrs
                if attrs[.foregroundColor] != nil { attrs.removeValue(forKey: .foregroundColor) }
                if attrs[.backgroundColor] != nil { attrs.removeValue(forKey: .backgroundColor) }
                mutable.setAttributes(attrs, range: range)
            }
            return AttributedString(mutable)
        } catch {
            return AttributedString(html)
        }
    }
}
