//
//  ViewController.swift
//  Mail A Coconut
//
//  Created by James Folk on 2/4/16.
//  Copyright © 2016 NJLIGames Ltd. All rights reserved.
//

import UIKit
import Stripe

class ViewController: UIViewController
{

    let SupportedPaymentNetworks = [PKPaymentNetworkVisa, PKPaymentNetworkMasterCard, PKPaymentNetworkAmex]
    // Replace these values with your application's keys
    
    // Find this at https://dashboard.stripe.com/account/apikeys
    //let stripePublishableKey = "pk_test_beGIzAWqb8512gIBGpRXFEdh"
    let stripePublishableKey = "pk_test_c7Z8l5pIYXglcN6mxzFx24YT"
    
    // To set this up, see https://github.com/stripe/example-ios-backend
    let backendChargeURLString = "http://localhost:5000/pay"
//    let backendChargeURLString = "https://mailacoconut.herokuapp.com/pay"
    
    
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
    
    func configureView() {
        
        if (!self.isViewLoaded()) {
            return
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        applePayButton.hidden = !PKPaymentAuthorizationViewController.canMakePaymentsUsingNetworks(SupportedPaymentNetworks)
        self.configureView()
        
        self.messageField.becomeFirstResponder()
        
        coconutMessage = CoconutMessage(
            image: UIImage(named: "iGT"),
            title: "Mail A Coconut Message",
            price: coconutMessagePrice,
            description: "Send an anonymous message on a coconut to a friend or an enemy!",
            message: self.messageField.text!,
            type: CoconutMessageType.Delivered(method: ShippingMethod.ShippingMethodOptions.first!))
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
    }
    
    func canBuy()->Bool
    {
        let message:String = self.messageField.text!
        
        if(!applePayButton.hidden &&
            ((message.characters.count > 0) && (message.characters.count < 12)))
        {
            return true
        }
        return false;
    }
    
    func buy()
    {
        Chartboost.showInterstitial(CBLocationHomeScreen)
        if(canBuy())
        {
            self.coconutMessage.setMessage(self.messageField.text!)
            
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
    }
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    @IBAction func hitReturn(sender: AnyObject) {
        buy()
        self.messageField.resignFirstResponder()
    }
    @IBAction func purchase(sender: AnyObject) {
        buy()
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
        
        switch (shippingAddress.State, shippingAddress.City, shippingAddress.Zip) {
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
    
    func paymentAuthorizationViewController(controller: PKPaymentAuthorizationViewController, didSelectShippingMethod shippingMethod: PKShippingMethod, completion: ((PKPaymentAuthorizationStatus, [PKPaymentSummaryItem]) -> Void)) {
        let shippingMethod = ShippingMethod.ShippingMethodOptions.filter {(method) in method.title == shippingMethod.identifier}.first!
        coconutMessage.swagType = CoconutMessageType.Delivered(method: shippingMethod)
        completion(PKPaymentAuthorizationStatus.Success, calculateSummaryItemsFromSwag(coconutMessage))
    }
}

