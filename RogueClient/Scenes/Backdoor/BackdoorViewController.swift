//
//  BackdoorViewController.swift
//  RogueClient
//
//  Created by Antonio Campos on 5/7/21.
//  Copyright © 2021 Winston Privacy, Inc. All rights reserved.
//

import Foundation
import UIKit
import Amplify
import AmplifyPlugins

class BackdoorViewController: UITableViewController {
    
    @IBOutlet weak var buildConfigurationLabel: UILabel!
    @IBOutlet weak var buildVersionLabel: UILabel!
    @IBOutlet weak var winstonApiUrlLabel: UILabel!
    @IBOutlet weak var cognitoUserIdLabel: UILabel!
    @IBOutlet weak var cognitoUserPoolIdLabel: UILabel!
    @IBOutlet weak var cognitoClientIdLabel: UILabel!
    @IBOutlet weak var vpnEndpointLabel: UILabel!
    @IBOutlet weak var vpnDnsLabel: UILabel!
    @IBOutlet weak var vpnAllowedIpsLabel: UILabel!
    @IBOutlet weak var vpnKeepAliveLabel: UILabel!
    @IBOutlet weak var vpnPublicKeyLabel: UILabel!
    @IBOutlet weak var tosAgreedLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            if let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
                buildVersionLabel.text = "\(version) (\(buildNumber))"
            }
        }
        
        buildConfigurationLabel.text = Config.Environment
        winstonApiUrlLabel.text = Config.WinstonApiUrl
        
        do {
           let plugin = try Amplify.Auth.getPlugin(for: "awsCognitoAuthPlugin") as! AWSCognitoAuthPlugin
        
           guard case let .awsMobileClient(awsmobileclient) = plugin.getEscapeHatch() else {
               print("Failed to fetch escape hatch")
               return
           }
             
            if awsmobileclient.isSignedIn {
                self.cognitoUserIdLabel.text = awsmobileclient.userSub
            } else {
                self.cognitoUserIdLabel.text = "No signed in."
            }
            
           } catch {
               print("Error occurred while fetching the escape hatch \(error)")
           }
        
        if let path = Bundle.main.path(forResource: "../amplifyconfiguration", ofType: "json") {
            do {
               let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                
                let jsonObject = jsonResult as? Dictionary<String, AnyObject>
                let auth = jsonObject?["auth"] as? Dictionary<String, AnyObject>
                let plugins = auth?["plugins"] as? Dictionary<String, AnyObject>
                let cognitoPlugin = plugins?["awsCognitoAuthPlugin"] as? Dictionary<String, AnyObject>
                
                let cognitoPool = cognitoPlugin?["CognitoUserPool"] as? Dictionary<String, AnyObject>
                let cognito = cognitoPool?["Default"] as? Dictionary<String, AnyObject>
                
                let cognitoUserPoolId = cognito?["PoolId"] as! String
                let cognitoClientId = cognito?["AppClientId"] as! String
                
                cognitoUserPoolIdLabel.text = cognitoUserPoolId
                cognitoClientIdLabel.text = cognitoClientId
              } catch {
                   print("unable to parse cognito file")
              }
        }
        
        vpnEndpointLabel.text = KeyChain.wgPeerEndpoint
        vpnDnsLabel.text = KeyChain.wgInterfaceDnsServers
        vpnAllowedIpsLabel.text = KeyChain.wgInterfaceAddresses
        vpnKeepAliveLabel.text = "\(KeyChain.wgPeerPersistentKeepAlive ?? Config.wgPeerPersistentKeepalive)"
        vpnPublicKeyLabel.text = KeyChain.wgInterfacePublicKey
        
        tosAgreedLabel.text = "\(UserDefaults.shared.hasUserConsent)"
    }
    
    @IBAction func clearAgreeTermsAndConditions(_ sender: Any) {
        UserDefaults.clearUserConsent()
        tosAgreedLabel.text = "\(UserDefaults.shared.hasUserConsent)"
        
        showFlashNotification(message: "Terms and conditions agreement has been cleared.", presentInView: (navigationController?.view)!)
    }
    
}
