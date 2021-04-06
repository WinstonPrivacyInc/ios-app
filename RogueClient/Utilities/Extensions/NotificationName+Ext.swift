//
//  NotificationName+Ext.swift
//  Rogue iOS app
//  https://github.com/WinstonPrivacyInc/rogue-ios
//
//  Created by Juraj Hilje on 2018-11-06.
//  Copyright (c) 2020 Privatus Limited.
//
//  This file is part of the Rogue iOS app.
//
//  The Rogue iOS app is free software: you can redistribute it and/or
//  modify it under the terms of the GNU General Public License as published by the Free
//  Software Foundation, either version 3 of the License, or (at your option) any later version.
//
//  The Rogue iOS app is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
//  or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
//  details.
//
//  You should have received a copy of the GNU General Public License
//  along with the Rogue iOS app. If not, see <https://www.gnu.org/licenses/>.
//

import Foundation

extension Notification.Name {
    
    // winston
    public static let PasswordResetSuccess = Notification.Name("passwordResetSuccess")
    public static let PasswordChangeSuccess = Notification.Name("passwordChangeSuccess")
    public static let EmailConfirmationSuccess = Notification.Name("emailConfirmationSuccess")
    public static let SignInSuccess = Notification.Name("signInSuccess")
    public static let SignOutSuccess = Notification.Name("signOutSuccess")
    
    // TODO: remove unnecessary ones
    public static let ServerSelected = Notification.Name("serverSelected")
    public static let Connect = Notification.Name("connect")
    public static let Disconnect = Notification.Name("disconnect")
    public static let TurnOffMultiHop = Notification.Name("turnOffMultiHop")
    public static let UpdateNetwork = Notification.Name("updateNetwork")
    public static let PingDidComplete = Notification.Name("pingDidComplete")
    public static let NetworkSaved = Notification.Name("networkSaved")
    public static let TermsOfServiceAgreed = Notification.Name("termsOfServiceAgreed")
    
    public static let SubscriptionDismissed = Notification.Name("subscriptionDismissed")
    public static let SubscriptionActivated = Notification.Name("subscriptionActivated")
    public static let ServiceAuthorized = Notification.Name("serviceAuthorized")
    public static let AuthenticationDismissed = Notification.Name("authenticationDismissed")
    public static let NewSession = Notification.Name("newSession")
    public static let ForceNewSession = Notification.Name("forceNewSession")
    public static let VPNConnectError = Notification.Name("vpnConnectError")
    public static let VPNConfigurationDisabled = Notification.Name("vpnConfigurationDisabled")
    public static let UpdateFloatingPanelLayout = Notification.Name("updateFloatingPanelLayout")
    public static let UpdateControlPanel = Notification.Name("updateControlPanel")
    public static let ProtocolSelected = Notification.Name("protocolSelected")
    public static let HideConnectionInfoPopup = Notification.Name("hideConnectionInfoPopup")
    public static let ShowConnectToServerPopup = Notification.Name("showConnectToServerPopup")
    public static let HideConnectToServerPopup = Notification.Name("hideConnectToServerPopup")
    public static let CenterMap = Notification.Name("centerMap")
    public static let UpdateGeoLocation = Notification.Name("updateGeoLocation")
    
}
