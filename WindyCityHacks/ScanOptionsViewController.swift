//
//  ScanOptionsViewController.swift
//  WindyCityHacks
//
//  Created by Emeka Ezike on 6/22/19.
//  Copyright © 2019 Emeka Ezike. All rights reserved.
//

import UIKit

class ScanOptionsViewController: UIViewController {

    let group = DispatchGroup()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    
}
