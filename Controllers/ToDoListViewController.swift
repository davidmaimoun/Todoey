//
//  ViewController.swift
//  Todoey
//
//  Created by David Maimoun on 08/02/2018.
//  Copyright © 2018 David Maimoun. All rights reserved.
//

import UIKit
import CoreData

class ToDoListViewController: UITableViewController {

    var itemArray = [Item]()
    
    //On veut charger les donnees de la categorie choisi, SI elle est choisi. Did set veut dire que ce que l'on mettra dans les braces ce fera au cas ou category prend une valeur
    var selectedCategory : Category? {
        didSet {
            loadItems()
        }
    }
    
    //On cherche la func dans app delegate qui nous servira de container
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        return itemArray.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        let item = itemArray[indexPath.row]
        
        cell.textLabel?.text = item.title
        
        //verifie pour ne pas qu'en scrollant, la checkmark apparaisse dans le cell qui le remplace
        cell.accessoryType = item.done ? .checkmark : .none
       
        return cell
    }
    
    //Pour dire au delegue que le row est selected (par ex surligne le row lorsque l'on clique dessus)
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //l'ordre est tres important, parce que si on efface la row avant de l'effacer dans le context, l'app saute
//        context.delete(itemArray[indexPath.row])
//        itemArray.remove(at: indexPath.row)
        
        //Pour afficher un checkmark par le code (cell for row est utilise pour agir si un row specifique, en l'occurence celui sur leque on a clique)
        //condition pour decocher si on clique une deuxieme fois
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
     
        //Sauve avec la propriete Done
        saveItems()
        
        //Pour deselectionner, ne pas laisser la couleur grise sur le row
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
   
    @IBAction func btnAddItems(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New ToDoey Item", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            
            let newItem = Item(context: self.context)
            newItem.title = textField.text!
            newItem.done = false
            newItem.parentCategory = self.selectedCategory //pour referencer la categorie d'ou l'on vient
          
            //Que se passe t il lorsque clique sur add item
            self.itemArray.append(newItem)
            
            //sauve les donnees lorsque l'on quitte l'app
            self.saveItems()
            
        }
        
        //Rajoute un text field dans l'alert action
        alert.addTextField(configurationHandler: ({ (alertTextField) in
            alertTextField.placeholder = "Create New Item"  //ecrit un hint
            textField = alertTextField
        }))
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
    }
    
    //sauve les donnees lorsque l'on quitte l'app
    func saveItems() {
        
        do {
          try context.save()
        }
        catch {
            print("Error encoding: \(error)")
        }
        
        tableView.reloadData()
    }
    
    func loadItems(with request : NSFetchRequest<Item> = Item.fetchRequest(),
                   predicate : NSPredicate? = nil) {
        
        //Pour que les items soit charges selon la categorie. O utilise categoryPredicate etc pour ne pas endommager le predicate du searchView (qui appelle cette fonction et risque de faire override au predicate et ne plus marcher)
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        
        if let additionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
        }
        else {
            request.predicate = categoryPredicate
        }
        
        do {
           itemArray = try context.fetch(request)
        }
        catch {
            print("error fetching data \(error)")
        }
        
        tableView.reloadData()
    }
    
}

extension ToDoListViewController : UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request : NSFetchRequest<Item> = Item.fetchRequest()
        
        //cd, pour etre insensible a la case et accents
         let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text! )
        
        //trier par title, ascending c'est pour le trie par ordre alphabetique
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        loadItems(with: request, predicate: predicate)
    }
    
    //change la liste lorsqu'on tape un mot
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            
            //pour faire disparaitre le clavier
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
        
    }
}
    




