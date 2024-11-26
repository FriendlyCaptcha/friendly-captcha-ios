/*!
 * Copyright (c) Friendly Captcha GmbH 2024.
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

/// Event that gets dispatched when the widget is completed.
///
/// This happens when the user's browser has successfully passed the captcha challenge.
@objc
public class WidgetCompleteEvent: NSObject, Codable {

    /// The current state of the widget, which will be `"completed"`.
    public let state: WidgetState


    /// The current captcha response token.
    public let response: String

    /// The ID of the widget from which the event originated.
    public let id: String
}

/// Event that gets dispatched when something goes wrong in the widget.
@objc
public class WidgetErrorEvent: NSObject, Codable {

    /// The current state of the widget, which will be `"error"`.
    public let state: WidgetState

    /// The current captcha response token.
    public let response: String

    /// The error that caused the event to be triggered.
    public let error: WidgetErrorData

    /// The ID of the widget from which the event originated.
    public let id: String
}

/// Event that gets dispatched when the widget expires.
///
/// This happens when the user takes too long to submit the captcha after it is solved.
@objc
public class WidgetExpireEvent: NSObject, Codable {
    public let state: WidgetState
    public let response: String
    public let id: String
}

/// Event that gets dispatched when the widget enters a new state.
@objc
public class WidgetStateChangeEvent: NSObject, Codable {

    /// The error that cased the state change, if any.
    ///
    /// If `state` is not equal to `"error"`, this value will be `nil`.
    public let error: WidgetErrorData?

    /// The ID of the widget from which the event originated.
    public let id: String

    /// The current captcha response token.
    public let response: String

    /// The new state of the widget.
    public let state: WidgetState

    // Required so this can be manually initialized in the FriendlyCaptcha.destroy() method.
    public init(error: WidgetErrorData?, id: String, response: String, state: WidgetState) {
        self.error = error
        self.id = id
        self.response = response
        self.state = state
    }
}

/// An object storing information about an error encountered by a widget.
@objc
public class WidgetErrorData: NSObject, Codable {

    /// A code describing the type of error encountered.
    public let code: WidgetErrorCode

    /// More details about the error to help debugging.
    ///
    /// This value is not localized and will change between versions.
    /// You can log it, but make sure not to depend on it in your code.
    public let detail: String
}

/// Error codes that can be returned by the widget.
///
/// In all cases, it's best to enable the "submit" button when the widget errors
/// so that the user can still perform the action, despite not having solved the captcha.
@objc
public enum WidgetErrorCode: Int, Codable {

    /// The user's browser could not connect to the Friendly Captcha API.
    case network_error

    /// The sitekey is invalid.
    case sitekey_invalid

    /// The sitekey is missing.
    case sitekey_missing

    /// Some other error occurred.
    case other

    private enum CodingKeys: String, CodingKey {
        case network_error
        case sitekey_invalid
        case sitekey_missing
        case other
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        switch rawValue {
        case CodingKeys.network_error.rawValue:
            self = .network_error
        case CodingKeys.sitekey_invalid.rawValue:
            self = .sitekey_invalid
        case CodingKeys.sitekey_missing.rawValue:
            self = .sitekey_missing
        case CodingKeys.other.rawValue:
            self = .other
        default:
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid WidgetErrorCode: \(rawValue)")
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .network_error:
            try container.encode(CodingKeys.network_error.rawValue)
        case .sitekey_invalid:
            try container.encode(CodingKeys.sitekey_invalid.rawValue)
        case .sitekey_missing:
            try container.encode(CodingKeys.sitekey_missing.rawValue)
        case .other:
            try container.encode(CodingKeys.other.rawValue)
        }
    }
}
