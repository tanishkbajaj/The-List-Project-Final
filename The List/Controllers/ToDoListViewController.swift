//
//  ToDoListViewController.swift
//  The List
//
//  Created by IMCS2 on 3/3/19.
//  Copyright © 2019 123 Apps Studio LLC. All rights reserved.
//

import UIKit
import Firebase

class ToDoListViewController: UIViewController, UITabBarDelegate  {
    
    @IBOutlet weak var todoItemTable: UITableView!
    
    private var route: AuthenticateRoute = AuthenticateRoute()
    private var itemShowViewModel: ItemShowViewModel = ItemShowViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
       // addBackgroundImage() // Added Background Image
        showNavigationBar()
        NotificationCenter.default.addObserver(self, selector: #selector(ToDoListViewController.handleAddItemDismiss), name: NSNotification.Name(rawValue: "addItemIsDismissed"), object: nil)
        let nibName = UINib(nibName: "ItemCellTableViewCell", bundle: nil)
        todoItemTable.register(nibName, forCellReuseIdentifier: "itemCellId")
        itemShowViewModel.getAllItemFromServer(userId: service.userModel.userId, completionHandler: {() in // Service TaskArray and CompletedTaskArray has been updated
            self.todoItemTable.reloadData()
        })
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        self.todoItemTable.reloadData()
    }
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
       // addBackgroundImage() 
        switch item.title! {
        case "Sign Off": // Log Off The User
            print("signOFF Here")
            try! Auth.auth().signOut()
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyBoard.instantiateViewController(withIdentifier: "loginStoryBoardId") as! ViewController
            service.resetAllProperties() // Reset all Properties for Fresh Use
            self.navigationController?.pushViewController(controller, animated: true)
            return
        case "Friends":
            let storyBoard = UIStoryboard(name: "Friends", bundle: nil)
            let controller = storyBoard.instantiateViewController(withIdentifier: "FriendsViewId") as! FriendsViewController
            self.navigationController?.pushViewController(controller, animated: true)
            return
        case "Categories":
            let storyBoard = UIStoryboard(name: "Catagories", bundle: nil)
            let controller = storyBoard.instantiateViewController(withIdentifier: "CatagoriesId") as! CatagoriesViewController
            self.navigationController?.pushViewController(controller, animated: true)
            return
        default:
            return
        }
    }
    
}

extension ToDoListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return service.taskArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemCellId", for: indexPath as IndexPath) as! ItemCellTableViewCell
        cell.commonInit(itemModel: service.taskArray[indexPath.row])
        return cell
    }
    
    // Swipe to complete the task
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let completed = UIContextualAction(style: .normal, title: "Completed") { (action, view, nil) in
            self.itemShowViewModel.completeTask(itemIndex: indexPath.row) // Complete Task
            self.todoItemTable.reloadData()
        }
        completed.backgroundColor = #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1)
        return UISwipeActionsConfiguration(actions: [completed])
    }
    
    // Swipe to Delete the Task
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleted = UIContextualAction(style: .normal, title: "Delete") { (action, view, nil) in
            self.itemShowViewModel.removeItemFromTask(itemIndex: indexPath.row)
            self.todoItemTable.reloadData()
        }
        deleted.backgroundColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
        return UISwipeActionsConfiguration(actions: [deleted])
    }
    
}

extension ToDoListViewController {
    
    @objc func handleAddItemDismiss() {
        todoItemTable.reloadData()
    }
    
    @IBAction func addListAction(_ sender: Any) {
        var controller = route.routeToAddItem()
        self.navigationController?.present(controller, animated: true, completion: nil)
    }
    
    @IBAction func completedListAction(_ sender: Any) {
        var controller = route.routeToCompletedItem()
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
}
