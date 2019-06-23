//
//  ItemViewController.swift
//  WindyCityHacks
//
//  Created by Emeka Ezike on 6/22/19.
//  Copyright © 2019 Emeka Ezike. All rights reserved.
//

import UIKit

class ItemViewController: UIViewController {
    
    var result : [String: AnyObject] = [:]
    var count = 1
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var ingredientsTA: UITextView!
    @IBOutlet var servingsLabel: UILabel!
    @IBOutlet var quantityLabel: UILabel!
    
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.tabBarController?.tabBar.isHidden = true
        nameLabel.text = result["name"] as! String;
        priceLabel.text = result["price"] as! String;
        ingredientsTA.text = result["ingredients"] as! String;
        servingsLabel.text = result["Servings"] as! String;
        


        let itemImageData = try! Data(contentsOf: URL(string: result["Img"] as! String)!)

        imageView.image = UIImage(data: itemImageData)


    }
    
    @IBAction func websiteBtnTapped(_ sender: Any) {
        if let url = URL(string: result["Site"] as! String) {
            UIApplication.shared.open(url)
        }
    }
    
    @IBAction func cartBtnTapped(_ sender: Any) {
        
    }
    
    @IBAction func downTapped(_ sender: Any) {
        if count > 1{
            count-=1
            quantityLabel.text = String(count)
        }
        
    }
    
    @IBAction func upTapped(_ sender: Any) {
        count+=1
        quantityLabel.text = String(count)
    }
}
