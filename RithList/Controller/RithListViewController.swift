
import UIKit
import CoreData

class RithListViewController: UITableViewController {
    
    var itemArray = [RithItem]()
    
    //.userDomainMask - users home directory,
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("RithListItems.plist")
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //load items fro rithListItems.plist on appear of view
        loadItems()
        searchBar.delegate = self
    }
    //MARK: - UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return itemArray.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "RithListItemCell", for: indexPath)
        let item = itemArray[indexPath.row]
        
        cell.textLabel?.text = item.title
        
        cell.accessoryType = item.checked ? .checkmark : .none
        
        return cell
    }
    //MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //firstly we gonna delete data from the data base
        context.delete(itemArray[indexPath.row])
        //then we gonna delete data from the item array
        itemArray.remove(at: indexPath.row)
        
        //itemArray[indexPath.row].checked = !itemArray[indexPath.row].checked
        
        saveItems()
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    //MARK: - add new items
    
    @IBAction func addButton(_ sender: UIBarButtonItem) {
        
        var newItem = UITextField()
        
        let alert = UIAlertController(title: "add new task", message: "type new task", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "add task", style: .default) { (action) in
            
            let newItemInRithList = RithItem(context: self.context)
            newItemInRithList.title = newItem.text!
            newItemInRithList.checked = false
            
            self.itemArray.append(newItemInRithList)
            
            self.saveItems()
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            newItem = alertTextField
        }
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    //MARK: - save new items into users home directory( from dataFilePath )
    func saveItems() {
        
        do {
            
            try context.save()
        } catch {
            print("Error saving context. \n \(error.localizedDescription)")
        }
        self.tableView.reloadData()
    }
    
    //    //MARK: - load items from users home directory ( from dataFilePath )
    func loadItems(with request: NSFetchRequest<RithItem> = RithItem.fetchRequest()) {
        
        do {
            itemArray = try context.fetch(request)
        } catch {
            print("Unexpected error with load items. \n \(error)")
        }
        
        tableView.reloadData()
    }
}

extension RithListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        let request: NSFetchRequest<RithItem> = RithItem.fetchRequest()
        
        //title CONTAINS %@ means, that when the method is gonna be triggered
        //we change %@ to searchBar.text! = title CONTAINS searchBar.text
        //cd means no case-sensative and no diacritic sensitive
        //check NSPredicate cheatsheet
        request.predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]

        do {
            itemArray = try context.fetch(request)
        } catch {
            print("Unexpected error with load items. \n \(error)")
        }
        
        tableView.reloadData()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchBar.text?.count == 0 {
            loadItems()
            
            DispatchQueue.main.async {
                
                searchBar.resignFirstResponder()
            }
        }
    }
}
