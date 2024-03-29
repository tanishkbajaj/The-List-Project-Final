//
//  UserAuthenticationViewModel.swift
//  The List
//
//
//  Created by IMCS2 on 3/3/19.
//  Copyright © 2019 123 Apps Studio LLC. All rights reserved.
//

import Foundation
import Firebase

class UserAuthenticateViewModel {
    var userModel: User
    private var message: String // Output Error Message Code for custom Message Display
    private var databaseRef: DatabaseReferenceModel // Database Reference Object
    private var userNode: DatabaseReference // Reference to the user node
    
    init(){
        self.userModel = User() // Initialize the User Struct
        message = ""
        self.databaseRef = DatabaseReferenceModel() // Referenece to Database Reference class
        self.userNode = self.databaseRef.ref.child("Users")
    }
    
    private func setupUserModel(id: String, email: String, firstName: String, lastName: String){
        userModel.userId = id
        userModel.userEmail = email
        userModel.firstName = firstName
        userModel.lastName = lastName
        
    }
}


///////////////////////////////////
// Signup User Extension Only
extension UserAuthenticateViewModel {
    
    // Sign up User
    func signUp(classRefernce: SignUpViewController, email: String, password: String, firstname: String, lastname: String){
        Auth.auth().createUser(withEmail: email, password: password) { (authData, error) in
            if let errorObj: Error = error { // There is an error creating the account
                self.message = errorObj.localizedDescription
                classRefernce.displayError(errorMsg: self.message)
            }
            if let authObj = authData { // The signup successfully Completed
                self.setupUserModel(id: authObj.user.uid, email: email, firstName: firstname, lastName: lastname)
                self.createUserEntry() // Creates the User profile in the database
                service.userModel = self.userModel // Set to the service
                classRefernce.userAuthenticateSuccess() // Call the callback function after success
            }
        }
    }
    
    // Creates a User Entry into the realtime database
    private func createUserEntry(){
        let userNode = self.userNode.child(userModel.userId) // Particular User Node
        userNode.setValue([
            "FirstName": userModel.firstName,
            "LastName" : userModel.lastName,
            "Email" : userModel.userEmail,
            "UserId" : userModel.userId,
            "Active" : true,
            "CategoryList": [],
            "FriendList": []
            ]) // Create the json tree for account creation
    }
    
}


///////////////////////////////////
// Signin User Extension Only
extension UserAuthenticateViewModel {
    
    // Login user with Authentication
    func login(classReference: ViewController, email: String, password: String){
        Auth.auth().signIn(withEmail: email, password: password) { (userResult, error) in
            print("User is Inside Signin Process")
            if let errorObj = error { // User failed to login
                classReference.displayError(errorMsg: errorObj.localizedDescription)
            }
            if let userObj = userResult { // User Successfully Signed in
                self.redirectAuthenticateUser(userId: userObj.user.uid, classReference: classReference, userEmail: email) // Handle redirection of authenticate user
            }
        }
    }
    
    // Check if user is logged in or not
    func isUserLoggedin() -> Bool {
        return Auth.auth().currentUser != nil
    }
    
    // Signin user without username and password
    func signinUserAutomatic(classReference: ViewController){
        if let userRef = Auth.auth().currentUser {
            redirectAuthenticateUser(userId: userRef.uid, classReference: classReference, userEmail: userRef.email!)
        }else {
            classReference.displayError(errorMsg: "You have been logged Out. Please signin again")
        }
    }
    
    // Complete process for authenticated User. Handles the callback function
    private func redirectAuthenticateUser(userId: String, classReference: ViewController, userEmail: String){
        self.userNode.observeSingleEvent(of: .value, with: { (allUserSnapShot) in
            if allUserSnapShot.hasChild(userId) { // UserId is present here
                self.userNode.child(userId).observeSingleEvent(of: .value) { (dataSnapshot) in // Retrieve User Data From Database
                    let value = dataSnapshot.value as? NSDictionary
                    let firstName = value?["FirstName"] as? String ?? ""
                    let lastName = value?["LastName"] as? String ?? ""
                    self.setupUserModel(id: userId, email: userEmail, firstName: firstName, lastName: lastName) // Setup the user Model
                    service.userModel = self.userModel // Set to the service
                    classReference.userAuthenticateSuccess() // Call Back Function in View Controller
                }
            } else {classReference.displayError(errorMsg: "")}
        })
    }
    //Forgot password Code
    func sendPasswordReset(classReference: ViewController, email: String){
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            print("User is Inside password reset Process")
            if let errorObj = error { // User failed to login
                classReference.displayError(errorMsg: errorObj.localizedDescription)
            }
        }
    }
    
}


