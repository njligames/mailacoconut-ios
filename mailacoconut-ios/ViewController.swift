//
//  ViewController.swift
//  Mail A Coconut
//
//  Created by James Folk on 2/4/16.
//  Copyright © 2016 NJLIGames Ltd. All rights reserved.
//

import UIKit
import Stripe
import AddressBookUI
import ContactsUI



class ViewController: UIViewController, PayPalPaymentDelegate, FlipsideViewControllerDelegate, CNContactPickerDelegate, UITextFieldDelegate
{
//    var environment:String = PayPalEnvironmentNoNetwork {
//        willSet(newEnvironment) {
//            if (newEnvironment != environment) {
//                PayPalMobile.preconnectWithEnvironment(newEnvironment)
//            }
//        }
//    }
    
    var environment:String = PayPalEnvironmentSandbox {
        willSet(newEnvironment) {
            if (newEnvironment != environment) {
                PayPalMobile.preconnectWithEnvironment(newEnvironment)
            }
        }
    }
    
    // You should use the PayPal-iOS-SDK+card-Sample-App target to enable this setting.
    // For your apps, you will need to link to the libCardIO and dependent libraries. Please read the README.md
    // for more details.
    var acceptCreditCards: Bool = true {
        didSet {
            payPalConfig.acceptCreditCards = acceptCreditCards
        }
    }
    
    var resultText = "" // empty
    var payPalConfig = PayPalConfiguration() // default

    let SupportedPaymentNetworks = [PKPaymentNetworkVisa, PKPaymentNetworkMasterCard, PKPaymentNetworkAmex]
    // Replace these values with your application's keys
    
    // Find this at https://dashboard.stripe.com/account/apikeys
    let stripePublishableKey = "pk_test_c7Z8l5pIYXglcN6mxzFx24YT"
    
    // To set this up, see https://github.com/stripe/example-ios-backend
//    let backendChargeURLString = "http://localhost:3000/pay"
    let backendChargeURLString = "https://mailacoconut.herokuapp.com/pay"
    
    
    // To set this up, see https://stripe.com/docs/mobile/apple-pay
    let ApplePaySwagMerchantID = "merchant.com.mailacoconut.us.ios"
    
    let coconutMessagePrice : NSDecimalNumber = 40.00 // this is in cents
    
    var coconutMessage: CoconutMessage! {
        didSet {
            // Update the view.
            self.configureView()
        }
    }
    
    @IBOutlet weak var messageField: UITextField!
    @IBOutlet weak var applePayButton: UIButton!
//    @IBOutlet weak var scrollView: UIScrollView!
    
    let minimumCharacterMessage = 1
    let maximumCharacterMessage = 12
    
    func configureView() {
        
        if (!self.isViewLoaded()) {
            return
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        
        let prefs = NSUserDefaults.standardUserDefaults()
        
        if prefs.boolForKey("AskAboutTutorial")
        {
            let alert:UIAlertController = UIAlertController(title: "Welcome", message: "Would you like to see a short tutorial?", preferredStyle: .Alert)
            
            let yesAction: UIAlertAction = UIAlertAction(title: "Yes", style: .Default) { action -> Void in
                //Do some stuff

                let newView = self.storyboard?.instantiateViewControllerWithIdentifier("TutorialViewController")
                self.navigationController?.pushViewController(newView!, animated: true)
//                
//                PlaceViewController *newView = [self.storyboard instantiateViewControllerWithIdentifier:@"storyBoardIdentifier"];
//                [self.navigationController pushViewController:newView animated:YES];
            }
            let noAction: UIAlertAction = UIAlertAction(title: "No", style: .Default) { action -> Void in
                //Do some stuff
            }
            alert.addAction(yesAction)
            alert.addAction(noAction)
            
            self.presentViewController(alert, animated: true, completion: nil)
            prefs.setValue(false, forKey: "AskAboutTutorial")
        }
        
        
        
//        NSString *error_message = "message"
//        UIAlertController * alert=   [UIAlertController alertControllerWithTitle:@"Error"
//        message:error_message
//        preferredStyle:UIAlertControllerStyleAlert];
        
//        UIAlertAction* yes = [UIAlertAction actionWithTitle:@"OK"
//        style:UIAlertActionStyleDefault
//        handler:^(UIAlertAction * action)
//        {
//        [alert dismissViewControllerAnimated:YES completion:nil];
//        [self.searchDisplayController setActive:NO];
//        }];
//        [alert addAction:ok];
//        [self presentViewController:alert animated:YES completion:nil];
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(ViewController.keyboardWillShow),
                                                         name: UIKeyboardWillShowNotification,
                                                         object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(ViewController.keyboardWillHide),
                                                         name: UIKeyboardWillHideNotification,
                                                         object: nil)
        
        applePayButton.enabled = !PKPaymentAuthorizationViewController.canMakePaymentsUsingNetworks(SupportedPaymentNetworks)
        
        self.configureView()
        self.messageField.delegate = self
        
//        self.messageField.becomeFirstResponder()
        
        
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.keyboardWillShow(_:)), name:UIKeyboardWillShowNotification, object: nil)
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.keyboardWillHide(_:)), name:UIKeyboardWillHideNotification, object: nil)
        
        
        
        
        
        
        // Set up payPalConfig
        payPalConfig.acceptCreditCards = acceptCreditCards;
        payPalConfig.merchantName = "NJLIGames Ltd."
        payPalConfig.merchantPrivacyPolicyURL = NSURL(string: "https://www.paypal.com/webapps/mpp/ua/privacy-full")
        payPalConfig.merchantUserAgreementURL = NSURL(string: "https://www.paypal.com/webapps/mpp/ua/useragreement-full")
        
        // Setting the languageOrLocale property is optional.
        //
        // If you do not set languageOrLocale, then the PayPalPaymentViewController will present
        // its user interface according to the device's current language setting.
        //
        // Setting languageOrLocale to a particular language (e.g., @"es" for Spanish) or
        // locale (e.g., @"es_MX" for Mexican Spanish) forces the PayPalPaymentViewController
        // to use that language/locale.
        //
        // For full details, including a list of available languages and locales, see PayPalPaymentViewController.h.
        
        payPalConfig.languageOrLocale = NSLocale.preferredLanguages()[0]
        
        // Setting the payPalShippingAddressOption property is optional.
        //
        // See PayPalConfiguration.h for details.
        
        payPalConfig.payPalShippingAddressOption = .Provided
        
        payPalConfig.rememberUser = true
        
        payPalConfig.defaultUserEmail = "mailacoconut@gmail.com"
        
        
        print("PayPal iOS SDK Version: \(PayPalMobile.libraryVersion())")
    }
    
    func keyboardWillShow(notification:NSNotification)
    {
        if let userInfo = notification.userInfo {
            if let keyboardSize = (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
                let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
                
                UIView.animateWithDuration(0.3, animations: {()
                    var f = self.view.frame
                    f.origin.y = -keyboardSize.height
                    self.view.frame = f
                })
                // ...
            } else {
                // no UIKeyboardFrameBeginUserInfoKey entry in userInfo
            }
        } else {
            // no userInfo dictionary in notification
        }
    }
    
    func keyboardWillHide(notification:NSNotification)
    {
        if let userInfo = notification.userInfo {
            if let keyboardSize = (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
                let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
                
                UIView.animateWithDuration(0.3, animations: {()
                    var f = self.view.frame
                    f.origin.y = 0.0
                    self.view.frame = f
                })
                // ...
            } else {
                // no UIKeyboardFrameBeginUserInfoKey entry in userInfo
            }
        } else {
            // no userInfo dictionary in notification
        }
    }
    
    
    override func viewWillDisappear(animated: Bool)
    {
        dismissKeyboard()
//        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
//        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        
        PayPalMobile.preconnectWithEnvironment(environment)
        
        
    }
    
    func canBuy()->Bool
    {
        let message:String = self.messageField.text!
        
        if(((message.characters.count >= minimumCharacterMessage) && (message.characters.count <= maximumCharacterMessage)))
        {
            return true
        }
        return false;
    }
    
    func buyPayPal()
    {
        if canBuy()
        {
            Chartboost.cacheRewardedVideo(CBLocationMainMenu)
            
            coconutMessage = CoconutMessage(image: UIImage(named: "iGT"),
                                            title: "Mail A Coconut Message",
                                            price: coconutMessagePrice,
                                            description: "Send an anonymous message on a coconut to a friend or an enemy!",
                                            message: self.messageField.text!,
                                            type: CoconutMessageType.Delivered(method: ShippingMethod.ShippingMethodOptions.first!),
                                            sku: "CMsg-0001")
            
            let picker = CNContactPickerViewController()
            picker.delegate = self
            
            self.presentViewController(picker, animated: true, completion: nil)
        }
        else
        {
            let alert = UIAlertController(title: "We're Sorry", message: "The Message must be at least \(minimumCharacterMessage) character and less than or equal to \(maximumCharacterMessage) characters.", preferredStyle: .Alert)
            let alertAction = UIAlertAction(title: "OK", style: .Default, handler:nil)
            alert.addAction(alertAction)
            presentViewController(alert, animated: true, completion: nil)
            
        }
        
        
    }
    
    func buyApplePay()
    {
        if PKPaymentAuthorizationViewController.canMakePaymentsUsingNetworks(SupportedPaymentNetworks)
        {
            if canBuy()
            {
                Chartboost.cacheRewardedVideo(CBLocationMainMenu)
                
                coconutMessage = CoconutMessage(image: UIImage(named: "iGT"),
                                                title: "Mail A Coconut Message",
                                                price: coconutMessagePrice,
                                                description: "Send an anonymous message on a coconut to a friend or an enemy!",
                                                message: self.messageField.text!,
                                                type: CoconutMessageType.Delivered(method: ShippingMethod.ShippingMethodOptions.first!),
                                                sku: "CMsg-0001")
                
                let request = PKPaymentRequest()
                request.merchantIdentifier = ApplePaySwagMerchantID
                request.supportedNetworks = SupportedPaymentNetworks
                request.merchantCapabilities = PKMerchantCapability.Capability3DS
                request.countryCode = "US"
                request.currencyCode = "USD"
                
                request.paymentSummaryItems = calculateSummaryItemsFromSwag(coconutMessage)
                request.requiredShippingAddressFields = PKAddressField.PostalAddress
                
                request.shippingMethods = calculateShippingMethod(coconutMessage)
                
                let applePayController = PKPaymentAuthorizationViewController(paymentRequest: request)
                applePayController.delegate = self
                presentViewController(applePayController, animated: true, completion: nil)
            }
            else
            {
                let alert = UIAlertController(title: "We're Sorry", message: "The Message must be at least \(minimumCharacterMessage) character and less than or equal to \(maximumCharacterMessage) characters.", preferredStyle: .Alert)
                let alertAction = UIAlertAction(title: "OK", style: .Default, handler:nil)
                alert.addAction(alertAction)
                presentViewController(alert, animated: true, completion: nil)
                
            }
        }
        else
        {
            let alert = UIAlertController(title: "We're Sorry", message: "Apple Pay is not turned on.  To turn it on go to: Settings -> Wallet & Apple Pay. Apple Pay requires iPhone 6, 6 plus, and later.", preferredStyle: .Alert)
            let alertAction = UIAlertAction(title: "OK", style: .Default, handler:nil)
            alert.addAction(alertAction)
            presentViewController(alert, animated: true, completion: nil)
        }
        
    }
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    @IBAction func hitReturn(sender: AnyObject) {
        self.messageField.resignFirstResponder()
    }
    
    @IBAction func purchasePayPal(sender: AnyObject) {
        buyPayPal()
        self.messageField.resignFirstResponder()
    }
    
    @IBAction func purchaseApplePay(sender: AnyObject) {
        buyApplePay()
        self.messageField.resignFirstResponder()
    }
    
    func calculateSummaryItemsFromSwag(coconutMessage: CoconutMessage) -> [PKPaymentSummaryItem] {
        var summaryItems = [PKPaymentSummaryItem]()
        let label = coconutMessage.title + "\n" + coconutMessage.message
        
        summaryItems.append(PKPaymentSummaryItem(label: label, amount: coconutMessage.price))
        
        switch (coconutMessage.swagType) {
        case .Delivered(let method):
            summaryItems.append(PKPaymentSummaryItem(label: "Shipping", amount: method.price))
        case .Electronic:
            break
        }
        
        summaryItems.append(PKPaymentSummaryItem(label: "Mail A Coconut", amount: coconutMessage.total()))
        
        return summaryItems
    }
    
    func calculateShippingMethod(coconutMessage: CoconutMessage) -> [PKShippingMethod] {
        var shippingMethods = [PKShippingMethod]()
        
        switch (coconutMessage.swagType) {
        case .Delivered(let method):
            
            
            for shippingMethod in ShippingMethod.ShippingMethodOptions {
                let method = PKShippingMethod(label: shippingMethod.title, amount: shippingMethod.price)
                method.identifier = shippingMethod.title
                method.detail = shippingMethod.description
                shippingMethods.append(method)
            }
            
        case .Electronic:
            break
        }
        return shippingMethods
    }
}

extension ViewController: PKPaymentAuthorizationViewControllerDelegate {
    func paymentAuthorizationViewController(controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, completion: ((PKPaymentAuthorizationStatus) -> Void)) {
        
        // 1
        let shippingAddress = self.createShippingAddressFromRef(payment.shippingAddress)
        
        // 2
        Stripe.setDefaultPublishableKey(stripePublishableKey)
        
        // 3
        STPAPIClient.sharedClient().createTokenWithPayment(payment) {
            (token, error) -> Void in
            
            if (error != nil) {
                NSLog("%@", error!)
                completion(PKPaymentAuthorizationStatus.Failure)
                return
            }
            let theToken = token!
            
            let url = NSURL(string: self.backendChargeURLString)
            let request = NSMutableURLRequest(URL: url!)
            request.HTTPMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            
            let username = "hack"
            let password = "thegibson"
            let loginString = NSString(format: "%@:%@", username, password)
            let loginData: NSData = loginString.dataUsingEncoding(NSUTF8StringEncoding)!
            let base64LoginString = loginData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength)
            
            request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
            
            let config = NSURLSessionConfiguration.defaultSessionConfiguration()
            let session = NSURLSession(configuration: config, delegate: nil, delegateQueue: NSOperationQueue())
            let body = ["stripeToken": theToken.tokenId,
                //                "amount": self.coconutMessage.total().decimalNumberByMultiplyingBy(cents),
                "amount": self.coconutMessagePrice.decimalNumberByMultiplyingBy(100),
                "description": self.coconutMessage.title,
                "message": self.coconutMessage.message,
                "timestamp": NSDate().timeIntervalSince1970,
                "shipping": [
                    "street": shippingAddress.Street!,
                    "city": shippingAddress.City!,
                    "state": shippingAddress.State!,
                    "zip": shippingAddress.Zip!,
                    "firstName": shippingAddress.FirstName!,
                    "lastName": shippingAddress.LastName!]
            ]
            
//            var error: NSError?
            do {
                request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(body, options: NSJSONWritingOptions())
            } catch {
                fatalError()
            }
            
            enum JSONError: String, ErrorType {
                case NoData = "ERROR: no data"
                case ConversionFailed = "ERROR: conversion from JSON failed"
            }
            
            let task = session.dataTaskWithRequest(request, completionHandler: {(data, response, error) in
                
//                if(Chartboost.hasInterstitial(CBLocationMainMenu))
//                {
//                    Chartboost.showInterstitial(CBLocationMainMenu)
//                }
//                else
//                {
//                    Chartboost.cacheInterstitial(CBLocationMainMenu)
//                }
                if(Chartboost.hasRewardedVideo(CBLocationMainMenu))
                {
                    Chartboost.showRewardedVideo(CBLocationMainMenu)
                }
                else
                {
                    Chartboost.cacheRewardedVideo(CBLocationMainMenu)
                }
                
                
                // notice that I can omit the types of data, response and error
                
                // your code
                if (error != nil) {
                    completion(PKPaymentAuthorizationStatus.Failure)
                } else {
                    completion(PKPaymentAuthorizationStatus.Success)
                }
                
                do {
                    guard let data = data else {
                        throw JSONError.NoData
                    }
                    guard let json = try NSJSONSerialization.JSONObjectWithData(data, options: []) as? NSDictionary else {
                        throw JSONError.ConversionFailed
                    }
                    print(json)
                    
                    
                    
                } catch let error as JSONError {
                    print(error.rawValue)
                } catch let error as NSError {
                    print(error.debugDescription)
                }
                
                
                
            });
            
            // do whatever you need with the task e.g. run
            task.resume()
        }
    }
    
    func paymentAuthorizationViewControllerDidFinish(controller: PKPaymentAuthorizationViewController) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func createShippingAddressFromRef(address: ABRecord!) -> Address {
        var shippingAddress: Address = Address()
        
        shippingAddress.FirstName = ABRecordCopyValue(address, kABPersonFirstNameProperty)?.takeRetainedValue() as? String
        shippingAddress.LastName = ABRecordCopyValue(address, kABPersonLastNameProperty)?.takeRetainedValue() as? String
        
        let addressProperty : ABMultiValueRef = ABRecordCopyValue(address, kABPersonAddressProperty).takeUnretainedValue() as ABMultiValueRef
        if let dict : NSDictionary = ABMultiValueCopyValueAtIndex(addressProperty, 0).takeUnretainedValue() as? NSDictionary {
            shippingAddress.Street = dict[String(kABPersonAddressStreetKey)] as? String
            shippingAddress.City = dict[String(kABPersonAddressCityKey)] as? String
            shippingAddress.State = dict[String(kABPersonAddressStateKey)] as? String
            shippingAddress.Zip = dict[String(kABPersonAddressZIPKey)] as? String
        }
        
        return shippingAddress
    }
    
    func paymentAuthorizationViewController(controller: PKPaymentAuthorizationViewController,
        didSelectShippingAddress address: ABRecord,
        completion: ((PKPaymentAuthorizationStatus, [PKShippingMethod], [PKPaymentSummaryItem]) -> Void))
    {
        let shippingAddress = createShippingAddressFromRef(address)
        
        switch (shippingAddress.State, shippingAddress.City, shippingAddress.Zip)
        {
        case (.Some(let state), .Some(let city), .Some(let zip)):
            //            completion(.Success, nil, nil)
//            completion(PKPaymentAuthorizationStatus.Success)
            completion(PKPaymentAuthorizationStatus.Success, self.calculateShippingMethod(coconutMessage), self.calculateSummaryItemsFromSwag(coconutMessage))
            break
        default:
            //            completion(.InvalidShippingPostalAddress, nil, nil)
            completion(PKPaymentAuthorizationStatus.InvalidShippingPostalAddress, self.calculateShippingMethod(coconutMessage), self.calculateSummaryItemsFromSwag(coconutMessage))
            break
        }
    }
    
    func paymentAuthorizationViewController(controller: PKPaymentAuthorizationViewController, didSelectShippingMethod shippingMethod: PKShippingMethod, completion: ((PKPaymentAuthorizationStatus, [PKPaymentSummaryItem]) -> Void))
    {
        let shippingMethod = ShippingMethod.ShippingMethodOptions.filter {(method) in method.title == shippingMethod.identifier}.first!
        coconutMessage.swagType = CoconutMessageType.Delivered(method: shippingMethod)
        completion(PKPaymentAuthorizationStatus.Success, calculateSummaryItemsFromSwag(coconutMessage))
    }
    
    
    
    
// MARK: - PayPalPaymentDelegate methods
    
    func payPalPaymentDidCancel(paymentViewController: PayPalPaymentViewController)
    {
        print("PayPal Payment Cancelled")
        paymentViewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func payPalPaymentViewController(paymentViewController: PayPalPaymentViewController, didCompletePayment completedPayment: PayPalPayment)
    {
        print("PayPal Payment Success !")
        paymentViewController.dismissViewControllerAnimated(true, completion: { () -> Void in
            // send completed confirmaion to your server
            
            
            
            
            var theMessage = ""
            let _message = completedPayment.custom
            let receivedData = _message.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)! as NSData
            do {
                if let response:NSDictionary = try NSJSONSerialization.JSONObjectWithData(receivedData, options:NSJSONReadingOptions.MutableContainers) as? Dictionary<String, AnyObject> {
                    theMessage = response.objectForKey("message") as! String
                    print(response)
                } else {
                    print("Failed...")
                }
            } catch let serializationError as NSError {
                print(serializationError)
            }
            
            let jsonString = "{\"data\": { \"object\": { \"metadata\": [ {\"name\":\"\(completedPayment.shippingAddress.recipientName)\"}, {\"firstName\":\"firstName\"}, {\"lastName\":\"lastName\"}, {\"street\":\"\(completedPayment.shippingAddress.line1)\"}, {\"city\":\"\(completedPayment.shippingAddress.city)\"}, {\"zip\":\"\(completedPayment.shippingAddress.postalCode)\"}, {\"message\":\"\(theMessage)\"} ] } } }"
            
            print(jsonString)
            
            let body = [
                "data": [
                    "object": [
                        "metadata": [
                            "name":completedPayment.shippingAddress.recipientName,
                            "firstName":"",
                            "lastName":"",
                            "street":completedPayment.shippingAddress.line1,
                            "city":completedPayment.shippingAddress.city,
                            "zip":completedPayment.shippingAddress.postalCode,
                            "message":theMessage
                        ]
                    ]
                ]
            ]
            
            let urlString = "https://mailacoconut.herokuapp.com/webhook"
            let url = NSURL(string: urlString)
            let request = NSMutableURLRequest(URL: url!)
            request.HTTPMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//            request.setValue("application/json", forHTTPHeaderField: "Accept")
            do {
                request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(body, options: NSJSONWritingOptions())
            } catch {
                fatalError()
            }
            let session = NSURLSession.sharedSession()
            let task = session.dataTaskWithRequest(request, completionHandler: {(data, response, error) in
                
                // notice that I can omit the types of data, response and error
                
                // your code
                
                
            })
            task.resume()
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
//            let data = _message.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
//            do {
//                let json = try NSJSONSerialization.JSONObjectWithData(data, options: []) as! [String: AnyObject]
//                if let message = json["message"] as? [String] {
//                    print(message)
//                }
//            } catch let error as NSError {
//                print("Failed to load: \(error.localizedDescription)")
//            }
            
            print("Here is your proof of payment:\n\n\(completedPayment)\n\nSend this to your server for confirmation and fulfillment. ")
        })
    }
    
    /*!
     * @abstract Invoked when the picker is closed.
     * @discussion The picker will be dismissed automatically after a contact or property is picked.
     */
    func contactPickerDidCancel(picker: CNContactPickerViewController)
    {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    /*!
     * @abstract Singular delegate methods.
     * @discussion These delegate methods will be invoked when the user selects a single contact or property.
     */
    func contactPicker(picker: CNContactPickerViewController, didSelectContactProperty contactProperty: CNContactProperty)
    {
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
        let contact = contactProperty.contact
        
        if let postalAddress = contactProperty.value as? CNPostalAddress
        {
            let shippingAddress = PayPalShippingAddress(recipientName: contact.givenName + " " + contact.familyName,
                                                        withLine1: postalAddress.street,
                                                        withLine2: "",
                                                        withCity: postalAddress.city,
                                                        withState: postalAddress.state,
                                                        withPostalCode: postalAddress.postalCode,
                                                        withCountryCode: postalAddress.ISOCountryCode.uppercaseString)
            
        
            
            let coconutMessageItem = PayPalItem(name: coconutMessage.title,
                                            withQuantity: 1,
                                            withPrice: coconutMessage.price,
                                            withCurrency: "USD",
                                            withSku: coconutMessage.sku)
            
            
            
            let items = [coconutMessageItem]
            let subtotal = PayPalItem.totalPriceForItems(items)
            let shipping = NSDecimalNumber(string: "0.00")
            let tax = NSDecimalNumber(string: "0.00")
            let paymentDetails = PayPalPaymentDetails(subtotal: subtotal,
                                                      withShipping: shipping,
                                                      withTax: tax)
            let total = subtotal.decimalNumberByAdding(shipping).decimalNumberByAdding(tax)
            
            let payment = PayPalPayment(amount: total,
                                        currencyCode: "USD",
                                        shortDescription: coconutMessage.description,
                                        intent: .Sale)
            
            payment.items = items
            payment.paymentDetails = paymentDetails
            payment.shippingAddress = shippingAddress;
            payment.custom = "{\"message\":\"\(coconutMessage.message)\"}"
            payment.softDescriptor = "Coconut Message"
            
            print(shippingAddress)
            if (payment.processable) {
                let paymentViewController = PayPalPaymentViewController(payment: payment, configuration: payPalConfig, delegate: self)
                presentViewController(paymentViewController!, animated: true, completion: { () -> Void in
                    // send completed confirmaion to your server
//                    print("Here is your proof of payment:\n\n\(completedPayment)\n\nSend this to your server for confirmation and fulfillment. ")
                })
            }
            else {
                // This particular payment will always be processable. If, for
                // example, the amount was negative or the shortDescription was
                // empty, this payment wouldn't be processable, and you'd want
                // to handle that here.
                print("Payment not processalbe: \(payment)")
            }
        }
        else
        {
            let alert = UIAlertController(title: "Error", message: "Please select the Postal Address of the recipient", preferredStyle: .Alert)
            let alertAction = UIAlertAction(title: "OK", style: .Default, handler:nil)
            alert.addAction(alertAction)
            presentViewController(alert, animated: true, completion: nil)
            
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        
        let newLength = text.utf16.count + string.utf16.count - range.length
        return newLength <= 10 // Bool
    }
    
//    func keyboardWillShow(notification:NSNotification){
//        
//        var userInfo = notification.userInfo!
//        var keyboardFrame:CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).CGRectValue()
//        keyboardFrame = self.view.convertRect(keyboardFrame, fromView: nil)
//        
////        var contentInset:UIEdgeInsets = self.scrollView.contentInset
////        contentInset.bottom = keyboardFrame.size.height
////        self.scrollView.contentInset = contentInset
//    }
//    
//    func keyboardWillHide(notification:NSNotification){
//        
////        var contentInset:UIEdgeInsets = UIEdgeInsetsZero
////        self.scrollView.contentInset = contentInset
//    }
}

