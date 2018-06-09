//
//  TableViewController.swift
//  Project Timer
//
//  Created by Christian Schneeweiss on 09.06.18.
//  Copyright © 2018 Christian Schneeweiss. All rights reserved.
//

import UIKit
import CoreData

class TableViewController: UITableViewController {

	var projects = [Project]()
	let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
	
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
		tableView.register(UINib(nibName: "ProjectsCell", bundle: nil), forCellReuseIdentifier: "ProjectsCell")
		
		loadProjects()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return projects.count
	}

	
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProjectsCell", for: indexPath) as! ProjectsCell

        cell.titleLabel.text = projects[indexPath.row].name

        return cell
    }
	
	
	//MARK: Core Data Methods
	
	func saveProjects() {
		do {
			try context.save()
		}
		catch {
			print("Error while saving Projects, \(error)")
		}
		
		tableView.reloadData()
	}
	
	func loadProjects() {
		let request : NSFetchRequest<Project> = Project.fetchRequest()
		do {
			projects = try context.fetch(request)
		}
		catch {
			print("Error while fetching Projects, \(error)")
		}
		
		tableView.reloadData()
	}
	
	//MARK: Table View Delegate Methods
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		performSegue(withIdentifier: "goToTimer", sender: self)
	}
	
	//MARK: Navigation
	
	@IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
		var newProjectTextField = UITextField()
		
		let alert = UIAlertController(title: "Project", message: "Create new Project", preferredStyle: .alert)
		alert.addTextField { (textField) in
			textField.placeholder = "New Project"
			newProjectTextField = textField
		}
		
		let action = UIAlertAction(title: "Create", style: .default) { (action) in
			let newProject = Project(context: self.context)
			newProject.name = newProjectTextField.text!
			
			self.projects.append(newProject)
			self.saveProjects()
			
			self.tableView.reloadData()
		}
		
		alert.addAction(action)
		present(alert, animated: true, completion: nil)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "goToTimer" {
			if let indexPath = tableView.indexPathForSelectedRow
			{
				let destinationVC = segue.destination as! ViewController
				destinationVC.selectedProject = projects[indexPath.row]
			}
		}
	}
	
}
