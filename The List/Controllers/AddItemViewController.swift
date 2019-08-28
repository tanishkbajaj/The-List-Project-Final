//
//  AddItemViewController.swift
//  The List
//
//  Created by IMCS2 on 3/4/19.
//  Copyright © 2019 123 Apps Studio LLC. All rights reserved.
//

import UIKit
import iOSDropDown

class AddItemViewController: UIViewController {

    @IBOutlet weak var itemName: UITextField!
    @IBOutlet weak var categoryDropDown: DropDown!
    @IBOutlet weak var friendDropDown: DropDown!
    
    private var itemAddViewModel: ItemAddViewModel = ItemAddViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addBackgroundImage()
        itemAddViewModel.getCategoryList(userId: service.userModel.userId) { (categoryArray) in
            self.renderDropDownForCategory(dropDownRef: self.categoryDropDown, valueArray: categoryArray)
            
        }
        
        itemAddViewModel.getFriendEmailList(userId: service.userModel.userId) { (friendEmailArray) in
            self.renderDropDownForFriendEmailList(dropDownRef: self.friendDropDown, valueArray: friendEmailArray)
        }
    }
    
    
    @IBAction func addItemAction(_ sender: Any) {
        itemAddViewModel.addItem(item: itemName.text!, category: categoryDropDown.text!, friendEmail: friendDropDown.text!, successHandler: {
            self.itemAddSuccess()
        }, errorHandler: {(errorMessage) in
            self.displayError(errorMessage: errorMessage)
        })
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

// Call Back Functions
extension AddItemViewController{
    private func itemAddSuccess(){
        self.dismiss(animated: true) { // Notify when the modal dissmiss with successful add
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "addItemIsDismissed"), object: nil)
        }
    }
    
    private func displayError(errorMessage: String){
        let alert = service.getErrorAlertHandler(errorMessage: errorMessage, buttonString: "Continue")
        self.present(alert, animated: true)
    }
}

extension AddItemViewController{
    //Render Drop Down Category
    private func renderDropDownForCategory(dropDownRef: DropDown, valueArray: [String]){
       
        _ = DropDown(frame: CGRect(x: 110, y: 140, width: 200, height: 30)) // set frame
        
        // The list of array to display. Can be changed dynamically
        var valueArray1 = ["Walmart", "Kroger", "Patel Brothers","Target","Whole Foods"]
        for i in valueArray {
            valueArray1.append(i)
        }
        print(valueArray1)
        let removedDuplicatesArray = removeDuplicates(array: valueArray1)
        //valueArray1 = valueArray
        dropDownRef.optionArray = removedDuplicatesArray
        
        
        
    }
    
    private func renderDropDownForFriendEmailList(dropDownRef: DropDown, valueArray: [String]){
        dropDownRef.optionArray = valueArray
    }
    //disappear the keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        self.view.endEditing(true)
    }
    
    func removeDuplicates(array: [String]) -> [String] {
        var encountered = Set<String>()
        var result: [String] = []
        for value in array {
            if encountered.contains(value) {
                // Do not add a duplicate element.
            }
            else {
                // Add value to the set.
                encountered.insert(value)
                // ... Append the value.
                result.append(value)
            }
        }
        return result
    }
    
}
