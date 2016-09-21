/*

  ViewController.swift
  CMAltimeterDemo

  The MIT License (MIT)

  Copyright (c) 2014 Erik Malyak

  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in all
  copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
  SOFTWARE.

*/

import UIKit
import CoreMotion // Make sure CoreMotion is imported

class ViewController: UIViewController {

    @IBOutlet weak var altLabel: UILabel! // Relative altitude label
    @IBOutlet weak var pressureLabel: UILabel! // Pressure label
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView! // Activity indicator
    @IBOutlet weak var altimeterSwitch: UISwitch! // Altimeter start / stop switch
    
    lazy var altimeter = CMAltimeter() // Lazily load CMAltimeter
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.activityIndicator.stopAnimating() // Hide activity indicator unless altimeter is on
        
    }
    
    func startAltimeter() {
        
        print("Started relative altitude updates.")
        
        // Check if altimeter feature is available
        if (CMAltimeter.isRelativeAltitudeAvailable()) {
            
            self.activityIndicator.startAnimating()
            
            // Start altimeter updates, add it to the main queue
            self.altimeter.startRelativeAltitudeUpdates(to: OperationQueue.main, withHandler: { (altitudeData:CMAltitudeData?, error:Error?) in
                
                if (error != nil) {
                    
                    // If there's an error, stop updating and alert the user
                    
                    self.altimeterSwitch.isOn = false
                    self.stopAltimeter()
                    
                    let alertView = UIAlertView(title: "Error", message: error!.localizedDescription, delegate: nil, cancelButtonTitle: "OK")
                    alertView.show()
                    
                } else {
                    
                    let altitude = altitudeData!.relativeAltitude.floatValue    // Relative altitude in meters
                    let pressure = altitudeData!.pressure.floatValue            // Pressure in kilopascals
                    
                    // Update labels, truncate float to two decimal points
                    self.altLabel.text = String(format: "%.02f", altitude)
                    self.pressureLabel.text = String(format: "%.02f", pressure)
                    
                }
                
            })
            
        } else {
            
            let alertView = UIAlertView(title: "Error", message: "Barometer not available on this device.", delegate: nil, cancelButtonTitle: "OK")
            alertView.show()
            
        }
        
    }
    
    func stopAltimeter() {
        
        // Reset labels
        self.altLabel.text = "-"
        self.pressureLabel.text = "-"
        
        self.altimeter.stopRelativeAltitudeUpdates() // Stop updates
        
        self.activityIndicator.stopAnimating() // Hide indicator
        
        print("Stopped relative altitude updates.")
        
    }
    
    @IBAction func switchDidChange(_ senderSwitch: UISwitch) {
        
        if (senderSwitch.isOn == true) {
            self.startAltimeter()
        } else {
            self.stopAltimeter()
        }
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

