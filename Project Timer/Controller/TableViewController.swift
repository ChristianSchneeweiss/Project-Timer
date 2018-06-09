//
//  TableViewController.swift
//  Project Timer
//
//  Created by Christian Schneeweiss on 09.06.18.
//  Copyright © 2018 Christian Schneeweiss. All rights reserved.
// Appicon : <div>Icons made by <a href="https://www.flaticon.com/authors/flat-icons" title="Flat Icons">Flat Icons</a> from <a href="https://www.flaticon.com/" title="Flaticon">www.flaticon.com</a> is licensed by <a href="http://creativecommons.org/licenses/by/3.0/" title="Creative Commons BY 3.0" target="_blank">CC 3.0 BY</a></div>

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
		let refreshControl = UIRefreshControl()
		tableView.refreshControl = refreshControl
		refreshControl.addTarget(self, action: #selector(refreshProjectData), for: .valueChanged)
		refreshControl.attributedTitle = NSAttributedString(string: "Updating ... ")
		
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

		let currentProject = projects[indexPath.row]
        cell.titleLabel.text = currentProject.name
		
		let (seconds, running) = getProjectDependentInformation(for: currentProject)
		let hourString = seconds/3600 > 10 ? "\(seconds / 3600)" : "0\(seconds / 3600)"
		let minutesString = seconds % 3600 / 60 > 10 ? "\(seconds % 3600 / 60)" : "0\(seconds % 3600 / 60)"
		cell.timeLabel.text = "\(hourString):\(minutesString)"
		cell.clockAnimationImage.image = running ? UIImage(named: "hourglass") : UIImage() // <div>Icons made by <a href="https://www.flaticon.com/authors/smashicons" title="Smashicons">Smashicons</a> from <a href="https://www.flaticon.com/" title="Flaticon">www.flaticon.com</a> is licensed by <a href="http://creativecommons.org/licenses/by/3.0/" title="Creative Commons BY 3.0" target="_blank">CC 3.0 BY</a></div>

        return cell
    }
	
	@objc func refreshProjectData() {
		tableView.reloadData()
		tableView.refreshControl?.endRefreshing()
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
	
	fileprivate func getProjectIntervals(_ project: Project) -> [ProjectTimeInterval] {
		let request : NSFetchRequest<ProjectTimeInterval> = ProjectTimeInterval.fetchRequest()
		let sorting = NSSortDescriptor(key: "startDate", ascending: true)
		request.sortDescriptors = [sorting]
		let predicate = NSPredicate(format: "parentProject.name MATCHES %@", project.name!)
		request.predicate = predicate
		
		do {
			return try context.fetch(request)
		}
		catch {
			print("Error while fetching intervals, \(error)")
		}
		
		return [ProjectTimeInterval]()
	}
	
	func getProjectDependentInformation(for project: Project) -> (UInt, Bool) {
		let intervals = getProjectIntervals(project)
		var secondsInProject : UInt = 0
		
		for interval in intervals {
			if !interval.running {
				let startDate = interval.startDate
				let endDate = interval.endDate
				secondsInProject += UInt(round((endDate?.timeIntervalSince(startDate!))!))
			}
			else {
				let currentDate = Date()
				secondsInProject += UInt(round(currentDate.timeIntervalSince(interval.startDate!)))
			}
		}
		
		if let running = intervals.last?.running {
			return (secondsInProject, running)
		}
		else {
			return (secondsInProject,false)
		}
		
		
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

extension TableViewController : CanBeUpdated {
	func update() {
		tableView.reloadData()
	}
}
