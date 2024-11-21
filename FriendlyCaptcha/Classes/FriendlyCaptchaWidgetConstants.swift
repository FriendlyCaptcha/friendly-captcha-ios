/**
 * Constants for the different states of the FriendlyCaptcha widget.
 * One of "init" | "reset" | "unactivated" | "activating" | "activated" | "requesting" | "solving" | "verifying" | "completed" | "expired" | "error" | "destroyed";
 */
public enum WidgetState: String, Codable {

    /**
     * The widget is being initialized, it was probably just created.
     */
    case initial = "init"

    /**
     * The widget was just reset - it will be `ready` again soon.
     */
    case reset

    /**
     * The widget is not yet activated. This means the widget is ready to be triggered so
     * it can start solving (in the background). It can be triggered by calling `start()`,
     * or by the user clicking the widget.
     */
    case unactivated

    /**
     * The widget is being activated. This means the widget is talking to the server to
     * request a challenge.
     */
    case activating

    /**
     * The widget is activated and awaiting user interaction in the form of a click
     * to continue (if the widget is in `interactive` mode).
     */
    case activated

    /**
     * The widget is requesting the final challenge from the server.
     */
    case requesting

    /**
     * The widget is solving the challenge.
     */
    case solving

    /**
     * The widget is verifying the solution, which means it is talking to the server to
     * receive the final verification response - which is what you will need to send
     * to your own server to verify.
     */
    case verifying

    /**
     * The widget has completed the challenge solving process.
     */
    case completed

    /**
     * The widget has expired. This can happen if the user has waited a long time without
     * using the captcha response. The user can click the widget to start again.
     */
    case expired

    /**
     * The widget has encountered an error.
     */
    case error

    /**
     * The widget has been destroyed. This means it is no longer usable.
     */
    case destroyed
}

/**
 * The theme for the widget.
 *
 * * `"light"` (default): a light theme with a white background.
 * * `"dark"`: a dark theme with a dark background.
 * * `"auto"`: the theme is automatically chosen based on the user's system preferences.
 */
public enum WidgetTheme {
    case light
    case dark
    case auto
}
