//
//  SelectSubscriptionViewController.swift
//  RogueClient
//
//  Created by Antonio Campos on 5/14/21.
//  Copyright © 2021 Winston Privacy, Inc. All rights reserved.
//

import Foundation
import UIKit

class SelectSubscriptionViewController: UIViewController {
    
    @IBOutlet weak var freePlanView: UIView!
    @IBOutlet weak var basicPlanView: UIView!
    @IBOutlet weak var proPlanView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let selectFreePlanGR = UITapGestureRecognizer(target: self, action:  #selector(self.selectFreePlan))
        self.freePlanView.addGestureRecognizer(selectFreePlanGR)
        
        let selectBasicPlanGR = UITapGestureRecognizer(target: self, action:  #selector(self.selectBasicPlan))
        self.freePlanView.addGestureRecognizer(selectBasicPlanGR)
        
        let selectProPlanGR = UITapGestureRecognizer(target: self, action:  #selector(self.selectProPlan))
        self.proPlanView.addGestureRecognizer(selectProPlanGR)
    }
    
    
    @objc func selectFreePlan(sender: UIGestureRecognizer) {
        KeyChain.rogueSubscription = "Free Plan 50mb/mo"
        showFlashNotification(message: "50mb activated for the next 30 days", presentInView: (navigationController?.view)!)
        self.connect()
    }
    
    private func connect() {
        DispatchQueue.delay(1) {
            NotificationCenter.default.post(name: Notification.Name.Connect, object: nil)
            self.dismissViewController(self)
        }
    }
    
    @objc func selectBasicPlan(sender: UIGestureRecognizer) {
        KeyChain.rogueSubscription = "Basic Plan 500mb/mo"
        showFlashNotification(message: "500mb activated for the next 30 days", presentInView: (navigationController?.view)!)
        self.connect()
    }
    
    @objc func selectProPlan(sender: UIGestureRecognizer) {
        KeyChain.rogueSubscription = "Pro Plan 1gb/mo"
        showFlashNotification(message: "1gb activated for the next 30 days", presentInView: (navigationController?.view)!)
        self.connect()
    }
    
}
