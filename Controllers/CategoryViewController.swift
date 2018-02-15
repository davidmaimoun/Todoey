//
//  CategoryViewController.swift
//  Todoey
//
//  Created by David Maimoun on 14/02/2018.
//  Copyright © 2018 David Maimoun. All rights reserved.
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController {
    
    var categoriesArray = [Category]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCategory()

    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return categoriesArray.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        cell.textLabel?.text = categoriesArray[indexPath.row].name
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
        performSegue(withIdentifier: "goToItems", sender: self)
        
    }
    
    //Pour que les Items soit specifique a la categorie cliquee, on doit preparer...
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ToDoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categoriesArray[indexPath.row]
        }
    }
    
    
    func saveCategory() {
        
        do {
            try context.save()
        }
        catch {
            print("Error in saving category : \(error)")
        }
        
        tableView.reloadData()
    }
    
    
    func loadCategory(with request : NSFetchRequest<Category> = Category.fetchRequest()) {
        
        do {
            categoriesArray = try context.fetch(request)
        }
        catch {
            print("error fetching data \(error)")
        }
        
        tableView.reloadData()
    }

    
    @IBAction func btnAdd(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: "Add a New Category", message: "", preferredStyle: .alert)
        var textField = UITextField()
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create a New Category"
            textField = alertTextField
        }
        
        let action = UIAlertAction(title: "Add Category", style: .default) { (action) in
            let newCategory = Category(context: self.context)
            newCategory.name = textField.text!
            self.categoriesArray.append(newCategory)
            
            self.saveCategory()
            }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
    }
    
}
