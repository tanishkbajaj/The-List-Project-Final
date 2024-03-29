//
//  ItemShowViewModel.swift
//  The List
//
//  Created by IMCS2 on 3/9/19.
//  Copyright © 2019 123 Apps Studio LLC. All rights reserved.
//

import Foundation
import Firebase

class ItemShowViewModel {
    
    private var databaseRef: DatabaseReferenceModel = DatabaseReferenceModel()
    private var taskNode: DatabaseReference
    
    init(){
        taskNode = databaseRef.ref.child("Tasks")
    }
    
    // This updates the service taskArray and taskCompletedArray directly
    func getAllItemFromServer(userId: String, completionHandler: @escaping () -> Void ){
        databaseRef.ref.child("Tasks").observeSingleEvent(of: .value) { (tasksSnapShot) in
            for taskSnapShot in tasksSnapShot.children {
                let taskDataSnapShot = taskSnapShot as! DataSnapshot
                let task = taskDataSnapShot.value as! NSDictionary // Particular Task Node
                if (task.value(forKey: "OwnerId") as! String == userId) || (task.value(forKey: "FriendId") as! String == userId) { // Check if this task is related to this User
                    let itemModel: ItemModel = self.setItemModel(itemObject: task, itemId: taskDataSnapShot.key)
                    if task.value(forKey: "IsComplete") as! Bool { // Task is Completed
                        service.completedTaskArray.insert(itemModel, at: 0) // Insert at Top
                    } else { // Task is not Completed
                        service.taskArray.insert(itemModel, at: 0) // Insert at TaskToDo Array
                    }
                }
            }
            completionHandler() // Call The Code that needs to be called after this
        }
    }
    
}

// Extensions for particular Item in an table
extension ItemShowViewModel {
    // Remove Item from an List
    func removeItemFromTask(itemIndex: Int){
        self.taskNode.child(service.taskArray[itemIndex].itemId).removeValue() // Remove the node
        service.taskArray.remove(at: itemIndex) // Remove from the array
    }
    
    // Completes a task from the list
    func completeTask(itemIndex: Int){
        self.taskNode.child(service.taskArray[itemIndex].itemId).updateChildValues([
            "IsComplete" : true,
            "DateCompleted" : service.getTodayDate()
            ]) // Update the Node in the task child
        var itemModel = service.taskArray[itemIndex] // Creates a Item Model
        itemModel.isCompleted = true
        itemModel.dateCompleted = service.getTodayDate()
        service.taskArray.remove(at: itemIndex)
        service.completedTaskArray.insert(itemModel, at: 0)
    }
    
    //Brings data from completed list back to main list
    func completeBackTolist(itemIndex: Int) {
        
        self.taskNode.child(service.completedTaskArray[itemIndex].itemId).updateChildValues([
            "IsComplete" : false,
            "DateAdded" : service.getTodayDate()
            ]) // Update the Node in the task child
        var itemModel = service.completedTaskArray[itemIndex] // Creates a Item Model
        itemModel.isCompleted = false
        itemModel.dateAdded = service.getTodayDate()
        service.completedTaskArray.remove(at: itemIndex)
        service.taskArray.insert(itemModel, at: 0)
        
    }
    
    // Remove Item from CompletedTask Array
    func removeItemFromCompleteTask(itemIndex: Int){
        self.taskNode.child(service.completedTaskArray[itemIndex].itemId).removeValue() // Remove the node
        service.completedTaskArray.remove(at: itemIndex) // Remove from the array
    }
    
    // Get all the Items of a particular Category
    func getItemsByCategory(category: String) -> [ItemModel]{
        var itemsArray: [ItemModel] = []
        // Search the task Array
        for item in service.taskArray {
            if item.category == category { // Category Matched
                itemsArray.insert(item, at: 0) // Insert inside the final array
            }
        }
        //Removed this code so that user cannot see items in completed list by category
        // Search the Complete task Array
//        for item in service.completedTaskArray {
//            if item.category == category { // Category Matched
//                itemsArray.insert(item, at: 0)
//            }
//        }
        return itemsArray
    }
    
    // Get all the details for a user. Get empty user Model if not found
    func getUserDetails(for userId: String, completionHandler: @escaping (_ userModel: User) -> Void){
        self.databaseRef.ref.child("Users").child(userId).observeSingleEvent(of: .value) { (userSnapshot) in
            if userSnapshot.exists() { // User Node Found
                let userDictonary = userSnapshot.value as! NSDictionary
                let userData: User = User(
                    userEmail: userDictonary.value(forKey: "Email") as! String,
                    userId: userSnapshot.key,
                    firstName: userDictonary.value(forKey: "FirstName") as! String,
                    lastName: userDictonary.value(forKey: "LastName") as! String,
                    categoryList: [],
                    friendList: []
                ) // User Model with all the populated data from firebase
                completionHandler(userData) // Code after everything is successful
            } else {
                completionHandler(User()) // Send an empty User Model
            }
        }
    }
}

// Private Func Goes Here
extension ItemShowViewModel {
    
    // Creates the Item Model Data Struct
    private func setItemModel(itemObject: NSDictionary, itemId: String) -> ItemModel {
        var itemModel: ItemModel = ItemModel(
            item: itemObject.value(forKey: "Name") as! String,
            category: itemObject.value(forKey: "Category") as! String,
            ownerId: itemObject.value(forKey: "OwnerId") as! String,
            friendId: itemObject.value(forKey: "FriendId") as! String,
            isCompleted: itemObject.value(forKey: "IsComplete") as! Bool,
            dateAdded: itemObject.value(forKey: "DateAdded") as! String,
            dateReIssued: itemObject.value(forKey: "DateReIssued") as! String,
            dateCompleted: itemObject.value(forKey: "DateCompleted") as! String
        )
        itemModel.itemId = itemId // Get Node ID of that item
        return itemModel
    }
}
