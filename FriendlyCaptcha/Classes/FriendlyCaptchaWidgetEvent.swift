/**
 * Event that gets dispatched when the widget is completed. This happens when the user's browser has successfully passed the captcha challenge.
 */
public struct WidgetCompleteEvent: Codable {
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
public struct WidgetErrorEvent: Codable {
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
public struct WidgetExpireEvent: Codable {
    public let state: WidgetState
    public let response: String
    public let id: String
}

/**
 * Event that gets dispatched when the widget enters a new state.
 */
public struct WidgetStateChangeEvent: Codable {

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
}

public struct WidgetErrorData: Codable {

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
public enum WidgetErrorCode: String, Codable {
    case network_error
    case sitekey_invalid
    case sitekey_missing
    case other
}
