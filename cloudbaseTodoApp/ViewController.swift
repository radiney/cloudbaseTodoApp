//
//  ViewController.swift
//  cloudbaseTodoApp
//
//  Created by user217360 on 6/4/22.
//

import UIKit
import FirebaseDatabase

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    private var dataSource: [(String, String)] = []
    private let database = Database.database().reference()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.prefersLargeTitles = true
        tableView.dataSource = self
        tableView.delegate = self
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAddBtn))
        
        fetchItemsFromDataBase()
        
    }

    @objc func didTapAddBtn(){
        let alert = UIAlertController(title: "Add item as a ToDo", message: " ", preferredStyle: .alert)
        alert.addTextField{field in field.placeholder = "Enter ToDo Item"}
        present(alert, animated: true)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { [weak self] _ in
                                      if let textField = alert.textFields?.first,
                                         let text = textField.text,
                                         !text.isEmpty{
                                          self?.saveToDo(item: text)
                }
            }
        ))	
    }
    
    func removeItemFromDatabase(itemKey: String){
        database.child("ToDoList/\(itemKey)").removeValue()
       // database.child("ToDoList/\()").removeValue()
        //let toDolistRef = Database.database().reference(withPath: "ToDoList")
        //let query = toDolistRef.queryOrderedByValue().queryEqual(toValue: item)
        //todo check which to delete if duplicate entries were made
        
       // query.observeSingleEvent(of: .value) { [weak self] snapShot in
           //guard let items = snapShot.value as? [String : String] else {
         //       return
          //  }
         //  for (key, _) in items {
         //       self?.database.child("ToDoList/\(key)").removeValue()
            //}
      //  }
    }
    
    func saveToDo(item: String){
        //let key = "item_\(dataSource.count + 1)"
        database.child("ToDoList").childByAutoId().setValue(item)
        //fetchItemsFromDataBase()
    }
    
    func fetchItemsFromDataBase(){
        database.child("ToDoList").observe(.value){ [weak self] snapShot in
            guard let items = snapShot.value as? [String: String] else {
                return
            }
            
            self?.dataSource.removeAll()
            
            let sortedItems = items.sorted { $0.0 < $1.0 }
            for (key, item) in sortedItems {
                self?.dataSource.append((key, item))
            }
            self?.tableView.reloadData()
        }	
        
    }

}

extension ViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = dataSource[indexPath.row].1
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
}

extension ViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        //animation of swipe delete
        if editingStyle == .delete {
            //todo remove item from database nad data source
            removeItemFromDatabase(itemKey: dataSource[indexPath.row].0)
            dataSource.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
           
            
        }
    }
}
