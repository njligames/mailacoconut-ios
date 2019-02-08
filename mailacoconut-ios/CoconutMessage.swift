//
//  CoconutMessage.swift
//  Mail A Coconut
//
//  Created by James Folk on 2/4/16.
//  Copyright © 2016 NJLIGames Ltd. All rights reserved.
//

import UIKit

struct ShippingMethod {
    let price: NSDecimalNumber
    let title: String
    let description: String
    
    init(price: NSDecimalNumber, title: String, description: String) {
        self.price = price
        self.title = title
        self.description = description
    }
    
    static let ShippingMethodOptions = [
        ShippingMethod(price: NSDecimalNumber(string: "0.00"), title: "USPS", description: "Delivered by your mail carrier."),
//        ShippingMethod(price: NSDecimalNumber(string: "100.00"), title: "Racecar", description: "Vrrrroom! Get it by tomorrow!"),
//        ShippingMethod(price: NSDecimalNumber(string: "9000000.00"), title: "Rocket Ship", description: "Look out your window!"),
    ]
}

enum CoconutMessageType {
    case delivered(method: ShippingMethod)
    case electronic
    
}

func ==(lhs: CoconutMessageType, rhs: CoconutMessageType) -> Bool {
    switch(lhs, rhs) {
    case (.delivered(let lhsVal), .delivered(let rhsVal)):
        return true
    case (.electronic, .electronic):
        return true
    default: return false
    }
}

struct CoconutMessage {
    let image: UIImage?
    let title: String
    let price: NSDecimalNumber
    let description: String
    var message: String
    var swagType: CoconutMessageType
    var sku: String
    
    init(image: UIImage?, title: String, price: NSDecimalNumber, description: String, message: String, type: CoconutMessageType, sku: String) {
        self.image = image
        self.title = title
        self.price = price
        self.description = description
        self.message = message
        self.swagType = type
        self.sku = sku
        
    }
    
    func total() -> NSDecimalNumber {
        var s = CoconutMessageType.delivered(method: ShippingMethod(price: 0.0, title: "asdf", description: "asdf"))
        
        
        switch (swagType) {
        case .delivered(let method):
            return price.adding(method.price)
        case .electronic:
            return price
        }
    }
    
    var priceString: String {
        let dollarFormatter: NumberFormatter = NumberFormatter()
        dollarFormatter.minimumFractionDigits = 2;
        dollarFormatter.maximumFractionDigits = 2;
        return dollarFormatter.string(from: price)!
    }
    
    mutating func setMessage(_ msg: String)
    {
        self.message = msg
    }
}
