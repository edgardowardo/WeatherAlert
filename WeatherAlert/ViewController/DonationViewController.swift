//
//  DonationViewController.swift
//  MatchCard
//
//  Created by EDGARDO AGNO on 28/10/2015.
//  Copyright (c) 2015 EDGARDO AGNO. All rights reserved.
//

import UIKit
import StoreKit
import MBProgressHUD

class DonationViewController : UIViewController {
    struct Product {
        static let Oneoff = "WT_T1_Donation"
        static let Great = "WT_T2_Donation"
        static let Smashing = "WT_T4_Donation"
    }
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var buttonOneOff: UIButton!
    @IBOutlet weak var buttonGreat: UIButton!
    @IBOutlet weak var buttonSmashing: UIButton!
    @IBOutlet weak var buttonRestore: UIButton!
    var products : [String : SKProduct] = [String : SKProduct]()
    var transactionInProgress = false
    var hud : MBProgressHUD?
    
    func showHud(text text : String) {
        self.hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        self.hud?.dimBackground = true
        self.hud?.labelText = text
    }
    func hideHud() {
        MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Remove Ads & Donate"
        self.logoImageView.layer.masksToBounds = true
        self.logoImageView.layer.cornerRadius = self.logoImageView.frame.size.width / 2
        self.logoImageView.backgroundColor = UIColor.flatPeterRiverColor()
        if let _ = self.presentingViewController {
            if self == (self.navigationController?.viewControllers.first!)! as UIViewController {
                self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: Selector("close:"))
            }
        }
        buttonGreat.enabled = false
        buttonGreat.alpha = 0.2
        buttonOneOff.enabled = false
        buttonOneOff.alpha = 0.2
        buttonSmashing.enabled = false
        buttonSmashing.alpha = 0.2
        buttonRestore.enabled = false
        buttonRestore.alpha = 0.2
        SKPaymentQueue.defaultQueue().addTransactionObserver(self)
        requestProductInfo()
    }
    
    @IBAction func handleRestore(sender: AnyObject) {
        if transactionInProgress {
            return
        }
        transactionInProgress = true
        SKPaymentQueue.defaultQueue().restoreCompletedTransactions()        
    }
    
    @IBAction func handleOneoff(sender: AnyObject) {
        if transactionInProgress {
            return
        }
        transactionInProgress = true
        let payment = SKPayment(product: self.products[Product.Oneoff]!)
        SKPaymentQueue.defaultQueue().addPayment(payment)
    }
    
    @IBAction func handleGreat(sender: AnyObject) {
        if transactionInProgress {
            return
        }
        transactionInProgress = true
        let payment = SKPayment(product: self.products[Product.Great]!)
        SKPaymentQueue.defaultQueue().addPayment(payment)
    }
    
    @IBAction func handleSmashing(sender: AnyObject) {
        if transactionInProgress {
            return
        }
        transactionInProgress = true
        let payment = SKPayment(product: self.products[Product.Smashing]!)
        SKPaymentQueue.defaultQueue().addPayment(payment)
    }
    
    @IBAction func close(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }

    func requestProductInfo() {
        if SKPaymentQueue.canMakePayments() {
            showHud(text: "Requesting apple")
            let productIdentifiers = NSSet(array: [Product.Oneoff, Product.Great, Product.Smashing])
            let productRequest = SKProductsRequest(productIdentifiers: productIdentifiers as! Set<String>)
            productRequest.delegate = self
            productRequest.start()
        }
        else {
            print("Cannot perform In App Purchases.")
        }
    }
}

extension DonationViewController : SKPaymentTransactionObserver {
    func paymentQueueRestoreCompletedTransactionsFinished(queue: SKPaymentQueue) {
        for t in queue.transactions {
            let transaction = t 
            if transaction.payment.productIdentifier == Product.Oneoff {
                print("Transaction restored successfully.")
                AppObject.sharedInstance?.isAdsShown = false
                transactionInProgress = false
                let alert = UIAlertController(title: "Restored", message: "One-off is now restored", preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "Okay", style: .Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
                break
            }
        }
    }

    func paymentQueue(queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case SKPaymentTransactionState.Purchased:
                print("Transaction completed successfully.")
                SKPaymentQueue.defaultQueue().finishTransaction(transaction)
                AppObject.sharedInstance?.isAdsShown = false
                transactionInProgress = false
            case SKPaymentTransactionState.Failed:
                print("Transaction Failed");
                SKPaymentQueue.defaultQueue().finishTransaction(transaction)
                transactionInProgress = false
            default:
                print(transaction.transactionState.rawValue)
            }
        }
    }
}

extension DonationViewController : SKProductsRequestDelegate {
    func productsRequest(request: SKProductsRequest, didReceiveResponse response: SKProductsResponse) {
        hideHud()
        if response.products.count != 0 {
            for product in response.products {
                let p = product 
                self.products[p.productIdentifier] = p
                switch p.productIdentifier {
                case Product.Oneoff :
                    UIView.animateWithDuration(0.35, animations: { () -> Void in
                        self.buttonOneOff.alpha = 1.0
                        self.buttonOneOff.enabled = true
                        self.buttonRestore.alpha = 1.0
                        self.buttonRestore.enabled = true
                    })
                case Product.Great :
                    UIView.animateWithDuration(0.35, animations: { () -> Void in
                        self.buttonGreat.alpha = 1.0
                        self.buttonGreat.enabled = true
                    })
                case Product.Smashing :
                    UIView.animateWithDuration(0.35, animations: { () -> Void in
                        self.buttonSmashing.alpha = 1.0
                        self.buttonSmashing.enabled = true
                    })
                default :
                    assertionFailure("Unknown product")
                }
             }
        }
        else {
            assertionFailure("There are no product")
        }
        if response.invalidProductIdentifiers.count != 0 {
            print(response.invalidProductIdentifiers.description)
        }
    }
}