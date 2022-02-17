//
//  Example.swift
//  FooFramework
//
//  Created by Ben  Thoburn on 16/02/2022.
//

import Foundation
import UIKit
//import Zaptastic_My_Attempt_2
import FooFramework
//public var VC = GameViewController()

open class Vehicle {
    open var Frait = 0
//    open var offnen  = 1
    open var integer: Int = 0 {
//        let VC = GameViewController()
        didSet {
            
            if integer == 1 {
//                shouldPerformSegue(withIdentifier: "Play", sender: self)
//                        //            self.removeFromSuperview()
//                        self.performSegue(withIdentifier: "Play", sender: self)
//                        //                    self.view = nil
                
            }
            
            
        }
    
        
    }
    open func changeIt(){
        integer = 1
    }
    
    public init() {
        
    }
   
}
