/**
 * Event that gets dispatched when the widget is completed. This happens when the user's browser has successfully passed the captcha challenge.
 */
@objc
public class WidgetCompleteEvent: NSObject, Codable {
    /**
     * The state of the widget: "completed"
     */
    public let state: WidgetState

    /**
     * The current captcha response token.
     */
    public let response: String

    /**
     * The widget ID that the event originated from.
     */
    public let id: String
}

/**
 * Event that gets dispatched when something goes wrong in the widget.
 */
@objc
public class WidgetErrorEvent: NSObject, Codable {
    /**
     * The state of the widget: "error"
     */
    public let state: WidgetState

    /**
     * The current captcha response token.
     */
    public let response: String

    /**
     * The error that caused the state change.
     */
    public let error: WidgetErrorData

    /**
     * The widget ID that the event originated from.
     */
    public let id: String
}

/**
 * Event that gets dispatched when the widget expires. This happens when the user takes too long to submit the captcha after it is solved.
 */
@objc
public class WidgetExpireEvent: NSObject, Codable {
    public let state: WidgetState
    public let response: String
    public let id: String
}

/**
 * Event that gets dispatched when the widget enters a new state.
 */
@objc
public class WidgetStateChangeEvent: NSObject, Codable {

    /**
     * The error that caused the state change, if any. `nil` if `state` is not equal to `"error"`.
     */
    public let error: WidgetErrorData?

    /**
     * The widget ID that the event originated from.
     */
    public let id: String

    /**
     * The current captcha response token.
     */
    public let response: String

    /**
     * The new state of the widget.
     */
    public let state: WidgetState

    // Required so this can be manually initialized in the FriendlyCaptcha.destroy() method.
    public init(error: WidgetErrorData?, id: String, response: String, state: WidgetState) {
        self.error = error
        self.id = id
        self.response = response
        self.state = state
    }
}

@objc
public class WidgetErrorData: NSObject, Codable {

    /**
     * The error code.
     */
    public let code: WidgetErrorCode

    /**
     * More details about the error to help debugging.
     * This value is not localized and will change between versions.
     *
     * You can log this, but make sure not to depend on it in your code.
     */
    public let detail: String
}

/**
 * Error codes that can be returned by the widget.
 *
 * * `"network_error"`: The user's browser could not connect to the Friendly Captcha API.
 * * `"sitekey_invalid"`: The sitekey is invalid.
 * * `"sitekey_missing"`: The sitekey is missing.
 * * `"other"`: Some other error occurred.
 *
 * In all cases it's the best practice to enable the "submit" button when the widget errors, so that the user can still
 * perform the action despite not having solved the captcha.
 */
@objc
public enum WidgetErrorCode: Int, Codable {
    case network_error
    case sitekey_invalid
    case sitekey_missing
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
