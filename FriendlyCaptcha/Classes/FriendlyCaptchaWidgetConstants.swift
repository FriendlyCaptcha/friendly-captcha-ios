/*!
 * Copyright (c) Friendly Captcha GmbH 2024.
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

/// Constants for the different states of the FriendlyCaptcha widget.
@objc
public enum WidgetState: Int, Codable {

    /// The widget is initialized—this is the initial state upon instantiation.
    case initial

    /// The widget was just reset.
    case reset

    /// The widget is ready to be triggered so it can start solving in the background.
    ///
    /// Can be triggered by calling `start()` or by the user clicking the widget.
    case unactivated

    /// The widget is talking to the server to request a challenge.
    case activating

    /// The widget is activated and awaiting user interaction in the form of a click to continue (if the widget is in `interactive` mode).
    case activated

    /// The widget is requesting the final challenge from the server.
    case requesting

    /// The widget is solving the challenge.
    case solving

    /// The widget is verifying the solution.
    ///
    /// This means it is talking to the server to receive the final verification response,
    /// which is what you will need to send to your own server to verify the captcha.
    case verifying

    /// The widget has completed the challenge solving process.
    case completed

    /// The widget has expired.
    ///
    /// This can happen if the user has waited a long time without using the captcha response.
    /// The user can click the widget to start again.
    case expired

    /// The widget has encountered an error.
    case error

    /// The widget has been destroyed.
    ///
    /// It is no longer usable in this state.
    case destroyed

    private enum CodingKeys: String, CodingKey {
        case initial = "init"
        case reset
        case unactivated
        case activating
        case activated
        case requesting
        case solving
        case verifying
        case completed
        case expired
        case error
        case destroyed
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .initial:
            try container.encode(CodingKeys.initial.rawValue)
        case .reset:
            try container.encode(CodingKeys.reset.rawValue)
        case .unactivated:
            try container.encode(CodingKeys.unactivated.rawValue)
        case .activating:
            try container.encode(CodingKeys.activating.rawValue)
        case .activated:
            try container.encode(CodingKeys.activated.rawValue)
        case .requesting:
            try container.encode(CodingKeys.requesting.rawValue)
        case .solving:
            try container.encode(CodingKeys.solving.rawValue)
        case .verifying:
            try container.encode(CodingKeys.verifying.rawValue)
        case .completed:
            try container.encode(CodingKeys.completed.rawValue)
        case .expired:
            try container.encode(CodingKeys.expired.rawValue)
        case .error:
            try container.encode(CodingKeys.error.rawValue)
        case .destroyed:
            try container.encode(CodingKeys.destroyed.rawValue)
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        switch rawValue {
        case CodingKeys.initial.rawValue:
            self = .initial
        case CodingKeys.reset.rawValue:
            self = .reset
        case CodingKeys.unactivated.rawValue:
            self = .unactivated
        case CodingKeys.activating.rawValue:
            self = .activating
        case CodingKeys.activated.rawValue:
            self = .activated
        case CodingKeys.requesting.rawValue:
            self = .requesting
        case CodingKeys.solving.rawValue:
            self = .solving
        case CodingKeys.verifying.rawValue:
            self = .verifying
        case CodingKeys.completed.rawValue:
            self = .completed
        case CodingKeys.expired.rawValue:
            self = .expired
        case CodingKeys.error.rawValue:
            self = .error
        case CodingKeys.destroyed.rawValue:
            self = .destroyed
        default:
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid WidgetState: \(rawValue)")
        }
    }
}

/// The display theme for the widget.
@objc
public enum WidgetTheme: Int {

    /// A light theme with a white background.
    case light

    /// A dark theme with a dark background.
    case dark

    /// **Default** The theme is automatically chosen based on the user's system preferences.
    case auto
}
