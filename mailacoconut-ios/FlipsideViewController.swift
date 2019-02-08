//
//  FlipsideViewController.swift
//  PayPal-iOS-SDK-Sample-App
//
//  Copyright (c) 2015-2016 PayPal, Inc. All rights reserved.
//

import UIKit

protocol FlipsideViewControllerDelegate {
  
  var acceptCreditCards: Bool { get set }
  var environment: String { get set }
  var resultText: String {get set}
}

class FlipsideViewController: UIViewController {
  
  @IBOutlet weak var environmentSegmentedControl: UISegmentedControl!
  @IBOutlet weak var acceptCreditCardsSwitch: UISwitch!
  @IBOutlet weak var payResultLabel: UILabel!
  @IBOutlet weak var payResultTextView: UITextView!
  
  var flipsideDelegate: FlipsideViewControllerDelegate?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    preferredContentSize = CGSize(width: 320.0, height: 480.0)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func logEnvironment() {
    print("Environment: \(flipsideDelegate?.environment). Accept credit cards? \(flipsideDelegate?.acceptCreditCards)")
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    logEnvironment()
    
    // select correct segment
    var numberOfSegments = environmentSegmentedControl.numberOfSegments - 1
    while (numberOfSegments >= 0) {
      let title = environmentSegmentedControl.titleForSegment(at: numberOfSegments)
      if title == flipsideDelegate!.environment {
        environmentSegmentedControl.selectedSegmentIndex = numberOfSegments
        break
      }
      numberOfSegments -= 1
    }

    acceptCreditCardsSwitch.isOn = flipsideDelegate!.acceptCreditCards
    
//#if !HAS_CARDIO
    acceptCreditCardsSwitch.isEnabled = false
//#endif
    
    let resultText = flipsideDelegate!.resultText
    if !resultText.isEmpty {
      print("\(resultText)")
      payResultTextView.text = resultText.trimmingCharacters(in: CharacterSet.whitespaces)
    } else {
      payResultTextView.isHidden = true
      payResultLabel.isHidden = true
    }
    payResultTextView.layer.cornerRadius = 8.0
  }
  
  
  
  @IBAction func environmentChanged(_ sender: AnyObject) {
    flipsideDelegate?.environment = environmentSegmentedControl.titleForSegment(at: environmentSegmentedControl.selectedSegmentIndex)!.lowercased()
    logEnvironment()
  }
  
  
  @IBAction func switchChanged(_ sender: AnyObject) {
    flipsideDelegate?.acceptCreditCards = acceptCreditCardsSwitch.isOn
    logEnvironment()
  }
  
}
