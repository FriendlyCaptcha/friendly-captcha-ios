// https://github.com/Quick/Quick

import Quick
import Nimble
import WebKit
import FriendlyCaptcha

class FriendlyCaptchaSpec: QuickSpec {
    override func spec() {
        var handle: FriendlyCaptcha!
        var window: UIWindow!

        beforeEach {
            window = UIWindow(frame: UIScreen.main.bounds)
            handle = FriendlyCaptcha(sitekey: "FCMGD7SIQS6JUH0G")

            window.rootViewController = handle.Widget()
            window.makeKeyAndVisible()
        }

        it("initializes") {
            expect(handle.getState()) == .initial
            expect(handle.getResponse()) == ""
        }

        it("is unactivated") {
            let expectation = QuickSpec.current.expectation(description: "unactivated")
            handle.onStateChange { (event) in
                if event.state == .unactivated {
                    expect(handle.getState()) == .unactivated
                    expect(handle.getResponse()) == ".UNACTIVATED"
                    expectation.fulfill()
                }
            }
            QuickSpec.current.waitForExpectations(timeout: 60)
        }

        it("starts") {
            let expectation = QuickSpec.current.expectation(description: "start")
            handle.onStateChange { event in

                // Wait to call handle.start() until the Widget has activated,
                // to make sure we don't call it before the JavaScript has run.
                if event.state == .unactivated {
                    handle.start()
                } else if event.state == .activated {
                    expect(handle.getState()) == .activated
                    expect(handle.getResponse()) == ".ACTIVATED"
                    expectation.fulfill()
                }
            }
            QuickSpec.current.waitForExpectations(timeout: 60)
        }

        it("resets") {
            let expectation = QuickSpec.current.expectation(description: "reset")
            handle.onStateChange { event in

                // Wait to call handle.start() until the Widget has activated,
                // to make sure we don't call it before the JavaScript has run.
                if event.state == .unactivated {
                    handle.start()

                // Then, after activation is done, try resetting.
                } else if event.state == .activated {
                    handle.reset()
                } else if event.state == .reset {
                    expect(handle.getState()) == .reset
                    expect(handle.getResponse()) == ".RESET"
                    expectation.fulfill()
                }
            }
            QuickSpec.current.waitForExpectations(timeout: 60)
        }

        it("can be destroyed") {
            expect(handle.Widget().viewIfLoaded).to(beAnInstanceOf(WKWebView.self))
            let expectation = QuickSpec.current.expectation(description: "destroy")
            handle.onStateChange { event in
                if event.state == .unactivated {
                    handle.start()
                } else if event.state == .activated {
                    handle.destroy()
                } else if event.state == .destroyed {
                    expect(handle.getState()) == .destroyed
                    expect(handle.getResponse()) == ".DESTROYED"
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        expect(handle.Widget().viewIfLoaded).to(beNil())
                        expectation.fulfill()
                    }
                }
            }
            QuickSpec.current.waitForExpectations(timeout: 60)
        }
    }
}
