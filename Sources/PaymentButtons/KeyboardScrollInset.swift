import UIKit
import SwiftUI

/// Bottom inset for a payment form scroll view. A hidden keyboard leaves no extra space.
public struct KeyboardScrollInset: Equatable {

    public let contentBottom: CGFloat
    public let indicatorBottom: CGFloat

    public static let cleared = KeyboardScrollInset(contentBottom: 0, indicatorBottom: 0)

    public static func afterChange(keyboardOverlap: CGFloat, safeAreaBottom: CGFloat) -> KeyboardScrollInset {
        let bottom = max(0, keyboardOverlap - safeAreaBottom)
        return KeyboardScrollInset(contentBottom: bottom, indicatorBottom: bottom)
    }
}

extension UIScrollView {

    func apply(_ inset: KeyboardScrollInset) {
        contentInset.bottom = inset.contentBottom
        verticalScrollIndicatorInsets.bottom = inset.indicatorBottom
        guard inset.contentBottom == 0 else { return }

        let maxOffsetY = max(0, contentSize.height - bounds.height)
        if contentOffset.y > maxOffsetY {
            contentOffset.y = maxOffsetY
        }
    }
}

public extension View {

    /// Drops the keyboard gap on this scroll view and any scroll view behind it.
    func clearsKeyboardScrollSpace() -> some View {
        background(KeyboardScrollInsetInstaller())
    }
}

private struct KeyboardScrollInsetInstaller: UIViewRepresentable {

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        view.isUserInteractionEnabled = false
        view.backgroundColor = .clear
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        DispatchQueue.main.async {
            let scrollViews = uiView.enclosingScrollViews()
            guard let owner = scrollViews.first else { return }
            owner.installKeyboardScrollInsetReset(alsoClearing: scrollViews.dropFirst())
        }
    }
}

private extension UIView {

    func enclosingScrollViews() -> [UIScrollView] {
        var scrollViews: [UIScrollView] = []
        var view = superview
        while let current = view {
            if let scrollView = current as? UIScrollView {
                scrollViews.append(scrollView)
            }
            view = current.superview
        }
        return scrollViews
    }
}

private final class KeyboardInsetObservation: NSObject {

    let tokens: [NSObjectProtocol]

    init(_ tokens: [NSObjectProtocol]) {
        self.tokens = tokens
    }

    deinit {
        tokens.forEach(NotificationCenter.default.removeObserver)
    }
}

private var keyboardInsetTokenKey: UInt8 = 0

private extension UIScrollView {

    func installKeyboardScrollInsetReset(alsoClearing others: some Collection<UIScrollView>) {
        guard objc_getAssociatedObject(self, &keyboardInsetTokenKey) == nil else { return }

        let center = NotificationCenter.default
        let change = center.addObserver(
            forName: UIResponder.keyboardWillChangeFrameNotification,
            object: nil,
            queue: .main
        ) { [weak self] note in
            self?.applyKeyboardFrame(note, alsoClearing: Array(others))
        }
        let hide = center.addObserver(
            forName: UIResponder.keyboardDidHideNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.clearKeyboardSpace(alsoClearing: Array(others))
        }
        objc_setAssociatedObject(self, &keyboardInsetTokenKey, KeyboardInsetObservation([change, hide]), .OBJC_ASSOCIATION_RETAIN)
    }

    func applyKeyboardFrame(_ note: Notification, alsoClearing others: [UIScrollView]) {
        let frame = note.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect ?? .zero
        let overlap = keyboardOverlap(with: frame)
        if overlap <= 0 {
            clearKeyboardSpace(alsoClearing: others)
            return
        }
        apply(KeyboardScrollInset.afterChange(keyboardOverlap: overlap, safeAreaBottom: safeAreaInsets.bottom))
        others.forEach { $0.apply(.cleared) }
    }

    func clearKeyboardSpace(alsoClearing others: [UIScrollView]) {
        apply(.cleared)
        others.forEach { $0.apply(.cleared) }
    }

    func keyboardOverlap(with keyboardFrame: CGRect) -> CGFloat {
        guard let window else { return 0 }
        let intersection = convert(bounds, to: window).intersection(keyboardFrame)
        guard !intersection.isNull else { return 0 }
        return intersection.height
    }
}
