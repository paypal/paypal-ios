import XCTest
@testable import PaymentButtons

class KeyboardScrollInset_Tests: XCTestCase {

    func testAfterChange_clearsInsetWhenTheKeyboardIsGone() {
        let inset = KeyboardScrollInset.afterChange(keyboardOverlap: 0, safeAreaBottom: 34)

        XCTAssertEqual(inset, .cleared)
        XCTAssertEqual(inset.contentBottom, 0)
        XCTAssertEqual(inset.indicatorBottom, 0)
    }

    func testAfterChange_usesOneInsetForTheKeyboardOverlap() {
        let inset = KeyboardScrollInset.afterChange(keyboardOverlap: 336, safeAreaBottom: 34)

        XCTAssertEqual(inset.contentBottom, 302)
        XCTAssertEqual(inset.indicatorBottom, 302)
    }

    func testApply_clearsStuckKeyboardSpaceAndStopsTheExtraScroll() {
        let scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: 320, height: 500))
        scrollView.contentSize = CGSize(width: 320, height: 800)
        scrollView.contentInset.bottom = 336
        scrollView.verticalScrollIndicatorInsets.bottom = 336
        scrollView.contentOffset.y = 620

        scrollView.apply(.cleared)

        XCTAssertEqual(scrollView.contentInset.bottom, 0)
        XCTAssertEqual(scrollView.verticalScrollIndicatorInsets.bottom, 0)
        XCTAssertEqual(scrollView.contentOffset.y, 300)
    }
}
