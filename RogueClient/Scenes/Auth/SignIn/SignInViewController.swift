//
//  SignInController.swift
//  Rogue iOS app
//  https://github.com/WinstonPrivacyInc/rogue-ios
//
//  Created by Fedir Nepyyvoda on 2016-07-12.
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
import KAPinField

class SignInViewController: UIViewController {

    // MARK: - @IBOutlets -
    
    @IBOutlet weak var emailTextField: UITextField! {
        didSet {
            emailTextField.delegate = self
        }
    }
    
    @IBOutlet weak var passwordTextField: UITextField! {
        didSet {
            passwordTextField.delegate = self
        }
    }
    
    private lazy var sessionManager: SessionManager = {
        let sessionManager = SessionManager()
        sessionManager.delegate = self
        return sessionManager
    }()
    
    private var isCognitoOperationInProgress = false
    private let hud = JGProgressHUD(style: .dark)
    private var actionType: ActionType = .signin
    
    @IBOutlet weak var confirmationCodeField: KAPinField!
    @IBOutlet weak var hiddenCodeField: UITextField!
    @IBOutlet var keyboardView: UIView!
    var passwordResetUserName: String = ""
    var passwordResetSuccess: Bool = false
    
    // MARK: - @IBActions -
    
    @IBAction func handleEmailInput(_ sender: AnyObject) {
        emailTextField.resignFirstResponder()
        passwordTextField.becomeFirstResponder()
    }
    
    @IBAction func signInToAccount(_ sender: AnyObject) {
        guard UserDefaults.shared.hasUserConsent else {
            actionType = .signin
            present(NavigationManager.getTermsOfServiceViewController(), animated: true, completion: nil)
            return
        }
        
        view.endEditing(true)
        startSignInProcess {
            
        }
    }
    
//    @IBAction func createAccount(_ sender: AnyObject) {
//        guard UserDefaults.shared.hasUserConsent else {
//            actionType = .signup
//            present(NavigationManager.getTermsOfServiceViewController(), animated: true, completion: nil)
//            return
//        }
//
//        startSignupProcess()
//    }
    
    @IBAction func presentForgotPasswordView(_ sender: Any) {
        present(NavigationManager.getForgotPasswordViewController(), animated: true)
    }
          
    @IBAction func presentSignUpView(_ sender: Any) {
        present(NavigationManager.getSignUpViewController(), animated: true)
    }
    
    @IBAction func openScanner(_ sender: AnyObject) {
        present(NavigationManager.getScannerViewController(delegate: self), animated: true)
    }
    
    @IBAction func restorePurchases(_ sender: AnyObject) {
        guard deviceCanMakePurchases() else { return }
        
        hud.indicatorView = JGProgressHUDIndeterminateIndicatorView()
        hud.detailTextLabel.text = "Restoring purchases..."
        hud.show(in: (navigationController?.view)!)
        
        IAPManager.shared.restorePurchases { account, error in
            self.hud.dismiss()
            
            if let error = error {
                self.showErrorAlert(title: "Restore failed", message: error.message)
                return
            }
            
            if account != nil {
                self.emailTextField.text = account?.accountId
                self.sessionManager.createSession()
            }
        }
    }
    
    // MARK: - View Lifecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.accessibilityIdentifier = "signInScreen"
        // navigationController?.navigationBar.prefersLargeTitles = false
        emailTextField.becomeFirstResponder()
        
        addObservers()
        hideKeyboardOnTap()
        
        hiddenCodeField.inputAccessoryView = keyboardView
        confirmationCodeField.properties.delegate = self
        confirmationCodeField.properties.numberOfCharacters = 6
        confirmationCodeField.properties.isSecure = false
        confirmationCodeField.properties.animateFocus = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // iOS 13 UIKit bug: https://forums.developer.apple.com/thread/121861
        // Remove when fixed in future releases
        if #available(iOS 13.0, *) {
            navigationController?.navigationBar.setNeedsLayout()
        }
    }
    
    // MARK: - Observers -
    
    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(subscriptionDismissed), name: Notification.Name.SubscriptionDismissed, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(subscriptionActivated), name: Notification.Name.SubscriptionActivated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(termsOfServiceAgreed), name: Notification.Name.TermsOfServiceAgreed, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(passwordWasReset), name: Notification.Name.PasswordResetSuccess, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(emailWasConfirmed), name: Notification.Name.EmailConfirmationSuccess, object: nil)
    }
    
    @objc private func emailWasConfirmed(notification: NSNotification) {
        
        if let data = notification.userInfo as? [String: String] {
            let email = data["email"]
            let password = data["password"]
                        
            if email != nil && password != nil {
                self.emailTextField.text = email
                self.passwordTextField.text = password
                
                self.startSignInProcess {
                    AccountService.shared.createAccount { result in
                        
                        switch result {
                        case .success(_):
                            NotificationCenter.default.post(name: Notification.Name.OpenSubscriptionSelectionScreen, object: nil, userInfo: data)
                            
                        case .failure(let error):
                            self.showAlert(title: "Error", message: error?.localizedDescription ?? "There was an error creating your account")
                        
                        }
                    }
                }
            }
        }
    }
    
    @objc private func passwordWasReset(notification: NSNotification) {
        
        if let data = notification.userInfo as? [String: String] {
            if let email = data["email"] {
                self.emailTextField.text = email
                self.passwordTextField.becomeFirstResponder()
            }
        }
        
        showFlashNotification(message: "Your password has been reset", presentInView: (navigationController?.view)!)
    }
    
    @objc func newSession() {
        startSignInProcess {
            
        }
    }
    
    @objc func forceNewSession() {
        startSignInProcess {
            
        }
    }
    
    @objc func termsOfServiceAgreed() {
        switch actionType {
        case .signin:
            signInToAccount(self)
        case .signup:
            // createAccount(self)
            print("do nothing here...")
        }
    }
    
    // MARK: - Methods -
    
    private func showIndicator(message: String) -> Void {
        hud.indicatorView = JGProgressHUDIndeterminateIndicatorView()
        hud.detailTextLabel.text = message
        hud.show(in: (navigationController?.view)!)
    }
    
    @IBAction func confirmationCodeUpdated(_ textField: UITextField) {
        // bug in library, must set token property first in order for text to be set
        confirmationCodeField.properties.token = confirmationCodeField.properties.token
        confirmationCodeField.text = textField.text
    }
    
    private func resendSignUpCode() {
        let username = (self.emailTextField.text ?? "").trim()
        
        showIndicator(message: "Requesting new code")
        isCognitoOperationInProgress = true
        
        Amplify.Auth.resendSignUpCode(for: username) { result in
            switch result {
            case .success(let deliveryDetails):
                log(info: "resendSignUpCode success \(deliveryDetails)")
                self.resendCodeSuccess()
            case .failure(let error):
                log(error: "resendSignUpCode \(error.errorDescription)")
                self.resendCodeFailure(authError: error)
            }
        }
        
    }
    
    private func startSignInProcess(completion: @escaping () -> Void) {
        
        guard !isCognitoOperationInProgress else { return }
        
        let username = (self.emailTextField.text ?? "").trim()
        let password = (self.passwordTextField.text ?? "").trim()
        
        isCognitoOperationInProgress = true
        
        guard ServiceStatus.isValidEmail(email: username) else {
            isCognitoOperationInProgress = false
            showAlert(title: "Invalid Email", message: "Please enter a valid email address.")
            return
        }
        
        guard ServiceStatus.isValidPassword(password: password) else {
            isCognitoOperationInProgress = false
            showAlert(title: "Invalid Password", message: "Please enter your password.")
            return
        }
        
        showIndicator(message: "Signin in...")
        
        Amplify.Auth.signIn(username: username, password: password) { result in
                switch result {
                case .success:
                    do {
                        let signInResult = try result.get()
                        // ref: https://docs.amplify.aws/lib/auth/signin_next_steps/q/platform/ios
                        
                        switch signInResult.nextStep {
                        
                        case .confirmSignInWithSMSMFACode(_, _):
                            // our cognito pool is not configured for sms authentication
                            log(info: "sign in confirmSignInWithSMSMFACode result")
                            self.signInResultNotSupport(message: "SMS sign in not supported. Contact support.")
                            
                        case .confirmSignInWithCustomChallenge(_):
                            // our cognito pool is not configured for custom answer challenge
                            log(info: "sign in confirmSignInWithCustomChallenge result")
                            self.signInResultNotSupport(message: "Challenge answer sign in not supported. Contact support.")
                        
                        case .confirmSignInWithNewPassword(_):
                            // this will happen if you add a user directly via aws cognito UI, not handling as we never do it that way
                            log(info: "sign in confirmSignInWithNewPassword result")
                            self.signInResultNotSupport(message: "Your user is in an invalid state.")
                            
                        case .resetPassword(_):
                            print("here")
                            
                        case .confirmSignUp(_):
                            log(info: "Email not confirmed during sign up.")
                            self.onConfirmSignUpResult()

                        case .done:
                            log(info: "Sign in success")
                            self.signInSuccess()
                            completion()
                        }
                        
                    } catch (let error) {
                        log(error: error.localizedDescription)
                        self.signInFailure(authError: AuthError(error: error))
                    }
                
                case .failure(let error):
                    log(error: "Sign in error \(error)")
                    self.signInFailure(authError: error)
                }
            }

    }
    
    private func onResetPasswordResult() {
        self.isCognitoOperationInProgress = false
        
        DispatchQueue.main.async {
            self.hud.dismiss()
            
            self.showActionAlert(
                title: "Password expired",
                message: "You current password has expired and needs to be reset in order to access your account",
                action: "Reset Now", actionHandler:  { (action) in
                    self.presentForgotPasswordView(self)
                })
        }
    }
    
    private func confirmSignUp(confirmationCode: String) -> Void {
        self.showIndicator(message: "Requesting new code...")
        self.isCognitoOperationInProgress = true
        
        let username = (self.emailTextField.text ?? "").trim()
        Amplify.Auth.confirmSignUp(for: username, confirmationCode: confirmationCode) { result in
                switch result {
                case .success:
                    log(info: "confirmSignUpSucess")
                    self.confirmSignUpSuccess()
                case .failure(let error):
                    log(error: "confirmSignUpError \(error.errorDescription)")
                    self.confirmSignUpFailure(error: error)
                }
            }
    }
    
    private func confirmSignUpSuccess() {
        self.isCognitoOperationInProgress = false
        DispatchQueue.main.async {
            self.hud.dismiss()
            self.startSignInProcess {
                
            }
        }
    }
    
    private func confirmSignUpFailure(error: AuthError) {
        self.isCognitoOperationInProgress = false
        DispatchQueue.main.async {
            self.hud.dismiss()
            self.showAlert(title: "Error", message: error.errorDescription)
        }
        
    }
    
    private func onConfirmSignUpResult() {
        self.isCognitoOperationInProgress = false
        
        DispatchQueue.main.async {
            self.hud.dismiss()
            
            self.showActionSheet(
                title: "Your account exists, but your email is not verified. Verify your email using the code sent to your email during sign up.",
                actions: ["I have a code", "I need a new code"],
                cancelAction: "Cancel",
                sourceView: self.view) { (selectedIndex) in
                
                if selectedIndex == 0 {
                    self.hiddenCodeField.becomeFirstResponder()
                } else if selectedIndex == 1 {
                    self.resendSignUpCode()
                }
            }
        }
    }
    
    private func signInResultNotSupport(message: String) -> Void {
        self.isCognitoOperationInProgress = false
        
        DispatchQueue.main.async {
            self.hud.dismiss()
            self.showAlert(title: "Error", message: message)
        }
    }
    
    private func signInSuccess() -> Void {
        self.isCognitoOperationInProgress = false
        
        DispatchQueue.main.async {
            self.createSessionSuccess()
            self.hud.dismiss()
        }
    }
    
    private func signInFailure(authError: AuthError) -> Void {
        self.isCognitoOperationInProgress = false
        
        DispatchQueue.main.async {
            self.hud.dismiss()
            self.showAlert(title: "Sign in failed", message: authError.errorDescription)
        }
    }
    
    private func resendCodeSuccess() -> Void {
        self.isCognitoOperationInProgress = false
        
        DispatchQueue.main.async {
            self.hud.dismiss()
            self.hiddenCodeField.becomeFirstResponder()
        }
    }
    
    private func resendCodeFailure(authError: AuthError) -> Void {
        self.isCognitoOperationInProgress = false
        
        DispatchQueue.main.async {
            self.hud.dismiss()
            self.showAlert(title: "Resend code failed", message: authError.errorDescription)
        }
    }
    
    
//    private func startSignupProcess() {
//        if KeyChain.tempUsername != nil {
//            present(NavigationManager.getCreateAccountViewController(), animated: true, completion: nil)
//            return
//        }
//
//        showIndicator(message: "Creating new account...")
//
//        let request = ApiRequestDI(method: .post, endpoint: Config.apiAccountNew, params: [URLQueryItem(name: "product_name", value: "IVPN Standard")])
//
//        ApiService.shared.requestCustomError(request) { [weak self] (result: ResultCustomError<Account, ErrorResult>) in
//            guard let self = self else { return }
//
//            self.hud.dismiss()
//
//            switch result {
//            case .success(let account):
//                KeyChain.tempUsername = account.accountId
//                self.present(NavigationManager.getCreateAccountViewController(), animated: true, completion: nil)
//            case .failure(let error):
//                self.showErrorAlert(title: "Error", message: error?.message ?? "There was a problem with creating a new account.")
//            }
//        }
//    }
    
    
    private func showUsernameError() {
        showErrorAlert(
            title: "You entered an invalid account ID",
            message: "Your account ID has to be in 'i-XXXX-XXXX-XXXX' or 'ivpnXXXXXXXX' format. You can find it on other devices where you are logged in and in the client area of the IVPN website."
        )
    }
    
    @objc private func subscriptionDismissed() {
        if Application.shared.authentication.isLoggedIn {
            navigationController?.dismiss(animated: true, completion: {
                NotificationCenter.default.post(name: Notification.Name.AuthenticationDismissed, object: nil)
            })
        }
    }
    
    @objc private func subscriptionActivated() {
        navigationController?.dismiss(animated: true, completion: {
            NotificationCenter.default.post(name: Notification.Name.ServiceAuthorized, object: nil)
        })
    }
    
    
}

extension SignInViewController : KAPinFieldDelegate {
  func pinField(_ field: KAPinField, didFinishWith code: String) {
    self.confirmSignUp(confirmationCode: code)
  }
}


// MARK: - SessionManagerDelegate -

extension SignInViewController {
    
    override func createSessionStart() {
        hud.indicatorView = JGProgressHUDIndeterminateIndicatorView()
        hud.detailTextLabel.text = "Creating new session..."
        hud.show(in: (navigationController?.view)!)
    }
    
    override func createSessionSuccess() {
        hud.dismiss()
        isCognitoOperationInProgress = false
        
        KeyChain.username = (self.emailTextField.text ?? "").trim()
        
        navigationController?.dismiss(animated: true, completion: {
            NotificationCenter.default.post(name: Notification.Name.ServiceAuthorized, object: nil)
            NotificationCenter.default.post(name: Notification.Name.UpdateFloatingPanelLayout, object: nil)
            NotificationCenter.default.post(name: Notification.Name.SignInSuccess, object: nil)
        })
    }
    
    override func createSessionServiceNotActive() {
        hud.dismiss()
        isCognitoOperationInProgress = false
        
        KeyChain.username = (self.emailTextField.text ?? "").trim()
        
        let viewController = NavigationManager.getSubscriptionViewController()
        viewController.presentationController?.delegate = self
        present(viewController, animated: true, completion: nil)
        
        NotificationCenter.default.post(name: Notification.Name.UpdateFloatingPanelLayout, object: nil)
    }
    
    override func createSessionAccountNotActivated(error: Any?) {
        hud.dismiss()
        isCognitoOperationInProgress = false
        
        KeyChain.tempUsername = (self.emailTextField.text ?? "").trim()
        Application.shared.authentication.removeStoredCredentials()
        
        let viewController = NavigationManager.getSelectPlanViewController()
        viewController.presentationController?.delegate = self
        present(viewController, animated: true, completion: nil)
        
        NotificationCenter.default.post(name: Notification.Name.UpdateFloatingPanelLayout, object: nil)
    }
    
    override func createSessionTooManySessions(error: Any?) {
        hud.dismiss()
        Application.shared.authentication.removeStoredCredentials()
        isCognitoOperationInProgress = false
        
        if let error = error as? ErrorResultSessionNew, let data = error.data {
            if data.upgradable {
                NotificationCenter.default.addObserver(self, selector: #selector(newSession), name: Notification.Name.NewSession, object: nil)
                NotificationCenter.default.addObserver(self, selector: #selector(forceNewSession), name: Notification.Name.ForceNewSession, object: nil)
                UserDefaults.shared.set(data.limit, forKey: UserDefaults.Key.sessionsLimit)
                UserDefaults.shared.set(data.upgradeToUrl, forKey: UserDefaults.Key.upgradeToUrl)
                present(NavigationManager.getUpgradePlanViewController(), animated: true, completion: nil)
                return
            }
        }
        
        showCreateSessionAlert(message: "You've reached the maximum number of connected devices")
    }
    
    override func createSessionAuthenticationError() {
        hud.dismiss()
        Application.shared.authentication.removeStoredCredentials()
        isCognitoOperationInProgress = false
        showErrorAlert(title: "Error", message: "Account ID is incorrect")
    }
    
    override func createSessionFailure(error: Any?) {
        var message = "There was an error creating a new session"
        
        if let error = error as? ErrorResultSessionNew {
            message = error.message
        }
        
        hud.dismiss()
        Application.shared.authentication.removeStoredCredentials()
        isCognitoOperationInProgress = false
        showErrorAlert(title: "Error", message: message)
    }
    
    override func twoFactorRequired(error: Any?) {
        hud.dismiss()
        isCognitoOperationInProgress = false
        present(NavigationManager.getTwoFactorViewController(delegate: self), animated: true)
    }
    
    override func twoFactorIncorrect(error: Any?) {
        var message = "Unknown error occurred"
        
        if let error = error as? ErrorResultSessionNew {
            message = error.message
        }
        
        hud.dismiss()
        isCognitoOperationInProgress = false
        showErrorAlert(title: "Error", message: message)
    }
    
    override func captchaRequired(error: Any?) {
        hud.dismiss()
        isCognitoOperationInProgress = false
        presentCaptchaScreen(error: error)
    }
    
    override func captchaIncorrect(error: Any?) {
        hud.dismiss()
        isCognitoOperationInProgress = false
        presentCaptchaScreen(error: error)
    }
    
    private func showCreateSessionAlert(message: String) {
        showActionSheet(title: message, actions: ["Log out from all other devices", "Try again"], sourceView: self.emailTextField) { index in
            switch index {
            case 0:
                self.startSignInProcess {
                    
                }
            case 1:
                self.startSignInProcess {
                    
                }
            default:
                break
            }
        }
    }
    
    private func presentCaptchaScreen(error: Any?) {
        if let error = error as? ErrorResultSessionNew, let imageData = error.captchaImage, let captchaId = error.captchaId {
            present(NavigationManager.getCaptchaViewController(delegate: self, imageData: imageData, captchaId: captchaId), animated: true)
        }
    }
    
}

// MARK: - UITextFieldDelegate -

extension SignInViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            emailTextField.resignFirstResponder()
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            emailTextField.resignFirstResponder()
            startSignInProcess {
                
            }
        }
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
    }
    
}

// MARK: - UIAdaptivePresentationControllerDelegate -

extension SignInViewController: UIAdaptivePresentationControllerDelegate {
    
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        if Application.shared.authentication.isLoggedIn {
            navigationController?.dismiss(animated: true, completion: {
                NotificationCenter.default.post(name: Notification.Name.AuthenticationDismissed, object: nil)
            })
        }
    }
    
}

// MARK: - ScannerViewControllerDelegate -

extension SignInViewController: ScannerViewControllerDelegate {
    
    func qrCodeFound(code: String) {
        emailTextField.text = code
        
        guard UserDefaults.shared.hasUserConsent else {
            DispatchQueue.async {
                self.actionType = .signin
                self.present(NavigationManager.getTermsOfServiceViewController(), animated: true, completion: nil)
            }
            
            return
        }
        
        startSignInProcess {
            
        }
    }
    
}

// MARK: - TwoFactorViewControllerDelegate -

extension SignInViewController: TwoFactorViewControllerDelegate {
    
    func codeSubmitted(code: String) {
        startSignInProcess {
            
        }
    }
    
}

// MARK: - CaptchaViewControllerDelegate -

extension SignInViewController: CaptchaViewControllerDelegate {
    
    func captchaSubmitted(code: String, captchaId: String) {
        startSignInProcess {
            
        }
    }
    
}

extension SignInViewController {
    
    enum ActionType {
        case signin
        case signup
    }
    
}
