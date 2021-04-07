//
//  AccountViewController.swift
//  Rogue iOS app
//  https://github.com/WinstonPrivacyInc/rogue-ios
//
//  Created by Juraj Hilje on 2020-03-23.
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

import UIKit
import JGProgressHUD
import Amplify

class AccountViewController: UITableViewController {
    
    // MARK: - @IBOutlets -
    
    @IBOutlet weak var accountView: AccountView!
    @IBOutlet weak var emailTableCell: UITableViewCell!
    @IBOutlet weak var passwordTableCell: UITableViewCell!
    
    
    private let hud = JGProgressHUD(style: .dark)
    private var viewModel = AccountViewModel(serviceStatus: Application.shared.serviceStatus, authentication: Application.shared.authentication)
    private var serviceType: ServiceType = Application.shared.serviceStatus.currentPlan == "IVPN Pro" ? .pro : .standard
    
    // MARK: - @IBActions -
    
    @IBAction func copyAccountID(_ sender: UIButton) {
//        guard let text = accountView.accountIdLabel.text else { return }
//        UIPasteboard.general.string = text
//        showFlashNotification(message: "Account ID copied to clipboard", presentInView: (navigationController?.view)!)
    }
    
    @IBAction func addMoreTime(_ sender: Any) {
        // present(NavigationManager.getSubscriptionViewController(), animated: true, completion: nil)
    }
    
    @IBAction func signOut(_ sender: Any) {
        showActionAlert(title: "Sign Out", message: "Are you sure you want to sign out?", action: "Sign out", actionHandler: { _ in
            self.signOut()
        })
    }
    
    @IBAction func presentChangePasswordView(_ send: Any) -> Void {
        performSegue(withIdentifier: "ChangePassword", sender: self)
    }
    
    @IBAction func presentChangeEmailView(_ send: Any) -> Void {
        performSegue(withIdentifier: "ChangeEmail", sender: self)
    }
    
    
    // MARK: - View Lifecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = UIColor.init(named: Theme.ivpnBackgroundQuaternary)
        
        view.accessibilityIdentifier = "accountScreen"
        navigationController?.navigationBar.prefersLargeTitles = false
        
        passwordTableCell.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(presentChangePasswordView)))
        emailTableCell.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(presentChangeEmailView)))
        
        initNavigationBar()
        addObservers()
        
        Application.shared.authentication.getUserAttribute(key: .email) { (email) in
            DispatchQueue.main.async {
                self.accountView.accountIdLabel.text = email ?? ""
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // accountView.initQRCode(viewModel: viewModel)
    }
    
    // MARK: - Observers -
    
    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(subscriptionActivated), name: Notification.Name.SubscriptionActivated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(passwordChanged), name: Notification.Name.PasswordChangeSuccess, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(emailChanged), name: Notification.Name.EmailChangeSuccess, object: nil)
    }
    
    // MARK: - Private methods -
    
    private func initNavigationBar() {
        if isPresentedModally {
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(dismissViewController(_:)))
        }
    }
    
    @objc private func subscriptionActivated() {
        let viewModel = AccountViewModel(serviceStatus: Application.shared.serviceStatus, authentication: Application.shared.authentication)
        accountView.setupView(viewModel: viewModel)
    }
    
    @objc private func passwordChanged() {
        showFlashNotification(message: "Your password was changed", presentInView: (navigationController?.view)!)
    }
    
    @objc private func emailChanged() {
        showFlashNotification(message: "Your email was changed", presentInView: (navigationController?.view)!)
    }
    
}

// MARK: - UITableViewDelegate -

extension AccountViewController {
    
//    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        if indexPath.row == 0 && serviceType == .standard {
//            return 220
//        }
//
//        if indexPath.row == 0 && serviceType == .pro {
//            return 150
//        }
//
//        return 71
//    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView {
            header.textLabel?.textColor = UIColor.init(named: Theme.ivpnLabel6)
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        if let footer = view as? UITableViewHeaderFooterView {
            footer.textLabel?.textColor = UIColor.init(named: Theme.ivpnLabel6)
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.init(named: Theme.ivpnBackgroundPrimary)
    }
    
}

// MARK: - SessionManagerDelegate -

extension AccountViewController {
    
    override func deleteSessionStart() {
        hud.indicatorView = JGProgressHUDIndeterminateIndicatorView()
        hud.detailTextLabel.text = "Removing session from IVPN server..."
        hud.show(in: (navigationController?.view)!)
    }
    
    override func deleteSessionSuccess() {
        hud.delegate = self
        hud.dismiss()
    }
    
    override func deleteSessionFailure() {
        hud.delegate = self
        hud.indicatorView = JGProgressHUDErrorIndicatorView()
        hud.detailTextLabel.text = "There was an error with removing session"
        hud.show(in: (navigationController?.view)!)
        hud.dismiss(afterDelay: 2)
    }
    
    override func deleteSessionSkip() {
        tableView.reloadData()
        
        showAlert(title: "Success", message: "You are successfully signed out") { _ in
            self.navigationController?.dismiss(animated: true)
        }
    }
    
}

// MARK: - JGProgressHUDDelegate -

extension AccountViewController: JGProgressHUDDelegate {
    
    func progressHUD(_ progressHUD: JGProgressHUD, didDismissFrom view: UIView) {
        tableView.reloadData()
        showAlert(title: "Success", message: "You are successfully signed out") { _ in
            self.navigationController?.dismiss(animated: true)
        }
    }
    
}
