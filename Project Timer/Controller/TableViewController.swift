//
//  TableViewController.swift
//  Project Timer
//
//  Created by Christian Schneeweiss on 09.06.18.
//  Copyright © 2018 Christian Schneeweiss. All rights reserved.
//  Appicon : <div>Icons made by <a href="https://www.flaticon.com/authors/smashicons" title="Smashicons">Smashicons</a> from <a href="https://www.flaticon.com/" title="Flaticon">www.flaticon.com</a> is licensed by <a href="http://creativecommons.org/licenses/by/3.0/" title="Creative Commons BY 3.0" target="_blank">CC 3.0 BY</a></div>

import UIKit
import RealmSwift
import Foundation
import ChameleonFramework
import PopupDialog

class TableViewController: UITableViewController {

	var projects : Results<Project>?
	var timer = Timer()
	var color = UIColor.flatSkyBlue()
	
	let realm = try! Realm()
	
	
	
	override func viewDidLoad() {
        super.viewDidLoad()
		
		tableView.register(UINib(nibName: "ProjectsCell", bundle: nil), forCellReuseIdentifier: "ProjectsCell")
		let refreshControl = UIRefreshControl()
		tableView.refreshControl = refreshControl
		refreshControl.addTarget(self, action: #selector(refreshProjectData), for: .valueChanged)
		refreshControl.attributedTitle = NSAttributedString(string: "Updating ... ")
		
		initaliseLongPressRecognizer(forSeconds: 0.75)
		
		tableView.separatorStyle = .none
		loadProjects()
		configureTimerAtStart()
		
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	
	
	func configureTimerAtStart() {
		timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true){ (timer) in
			self.update()
		}
	}
	
	fileprivate func initaliseLongPressRecognizer(forSeconds time : Double) {
		let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPress))
		longPressRecognizer.minimumPressDuration = CFTimeInterval(time)
		self.view.addGestureRecognizer(longPressRecognizer)
	}
	
	@objc func longPress(longPressGestureRecognizer: UILongPressGestureRecognizer) {
		
		if longPressGestureRecognizer.state == UIGestureRecognizerState.began {
			
			let touchPoint = longPressGestureRecognizer.location(in: self.view)
			if let indexPath = tableView.indexPathForRow(at: touchPoint) {
				
				print(projects![indexPath.row].name)
				let selectedProject = projects![indexPath.row]
				
				createProjectActionSheet(for: selectedProject)
			}
		}
	}
	
    // MARK: - Table view data source

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return projects?.count ?? 1
	}

	
	fileprivate func cellText(_ currentProject: Project, _ cell: ProjectsCell) {
		let (seconds, running) = getProjectDependentInformation(for: currentProject)
		let hourString = seconds/3600 > 10 ? "\(seconds / 3600)" : "0\(seconds / 3600)"
		let minutesString = seconds % 3600 / 60 > 10 ? "\(seconds % 3600 / 60)" : "0\(seconds % 3600 / 60)"
		cell.timeLabel.text = "\(hourString):\(minutesString)"
		cell.clockAnimationImage.image = running ? UIImage(named: "hourglass") : UIImage()  // <div>Icons made by <a href="https://www.flaticon.com/authors/smashicons" title="Smashicons">Smashicons</a> from <a href="https://www.flaticon.com/" title="Flaticon">www.flaticon.com</a> is licensed by <a href="http://creativecommons.org/licenses/by/3.0/" title="Creative Commons BY 3.0" target="_blank">CC 3.0 BY</a></div>
	}
	
	fileprivate func cellUI(_ indexPath: IndexPath, _ cell: ProjectsCell) {
		if let currentProject = projects?[indexPath.row] {
			cell.titleLabel.text = currentProject.name
			let bColor = color?.darken(byPercentage: CGFloat(Double(indexPath.row)/Double(projects!.count)))
			cell.backgroundColor = bColor
			let contrastColor = UIColor(contrastingBlackOrWhiteColorOn: bColor, isFlat: true)
			cell.titleLabel.textColor = contrastColor
			cell.timeLabel.textColor = contrastColor
			
			cellText(currentProject, cell)
		}
		else {
			cell.titleLabel.text = "No Projects have been added yet"
			cell.timeLabel.text = ""
		}
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProjectsCell", for: indexPath) as! ProjectsCell
		
		cellUI(indexPath, cell)

        return cell
    }
	
	@objc func refreshProjectData() {
		tableView.reloadData()
		tableView.refreshControl?.endRefreshing()
	}
	
	//MARK: Realm Data Methods
	
	
	func loadProjects() {
		projects = realm.objects(Project.self).filter("archiv == false")
		tableView.reloadData()
	}
	
	func getProjectDependentInformation(for project: Project) -> (UInt, Bool) {
		let intervals = project.intervals.sorted(byKeyPath: "startDate", ascending: true)
		var secondsInProject : UInt = 0
		
		for interval in intervals {
			if !interval.running {
				let startDate = interval.startDate
				let endDate = interval.endDate ?? Date()
				secondsInProject += UInt(round(endDate.timeIntervalSince(startDate)))
			}
			else {
				let currentDate = Date()
				secondsInProject += UInt(round(currentDate.timeIntervalSince(interval.startDate)))
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

	
	
	
	@IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
		var newProjectTextField = UITextField()
		
		let alert = UIAlertController(title: "Project", message: "Create new Project", preferredStyle: .alert)
		alert.addTextField { (textField) in
			textField.placeholder = "New Project"
			newProjectTextField = textField
		}
		
		let addProjectAction = UIAlertAction(title: "Create", style: .default) { (action) in
			do {
				if newProjectTextField.text! != "" {
					try self.realm.write {
						let newProject = Project()
						newProject.name = newProjectTextField.text!
						self.realm.add(newProject)
					}
					self.tableView.reloadData()
				}
			}
			catch {
				print("Error while writing to realm, \(error)")
			}
		}
		
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
		
		alert.addAction(addProjectAction)
		present(alert, animated: true, completion: nil)
	}
	
	//MARK: Navigation
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "goToTimer" {
			if let indexPath = tableView.indexPathForSelectedRow
			{
				let destinationVC = segue.destination as! ViewController
				destinationVC.selectedProject = projects?[indexPath.row]
				destinationVC.delegate = self
				destinationVC.bColor = color?.darken(byPercentage: CGFloat(Double(indexPath.row)/Double(projects!.count)))
			}
		}
	}
	
	//MARK: Color Picker
	
	@IBAction func colorButtonPressed(_ sender: UIBarButtonItem) {
		// Create a custom view controller
		let colorVC = ColorPopUp(nibName: "ColorPopUp", bundle: nil)
		colorVC.delegate = self
		
		// Create the dialog
		let popup = PopupDialog(viewController: colorVC)
	
		// Present dialog
		present(popup, animated: true, completion: nil)
		
	}
}

extension TableViewController : CanBeUpdated {
	func update() {		
		tableView.reloadData()
	}
}

extension TableViewController {
	
	//MARK: Long Press Functionality

	
	fileprivate func createProjectActionSheet(for selectedProject: Project) {
		let actionSheetPicker = UIAlertController(title: selectedProject.name, message: "What do You want to do with this Project", preferredStyle: .actionSheet)
		let editAction = self.editAction(selectedProject)
		let deleteAction = self.deleteAction(selectedProject)
		let archivAction = self.archivAction(selectedProject)
		
		
		
		actionSheetPicker.addAction(editAction)
		actionSheetPicker.addAction(archivAction)
		actionSheetPicker.addAction(deleteAction)
		actionSheetPicker.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
		present(actionSheetPicker, animated: true, completion: nil)
	}
	
	fileprivate func editAction(_ selectedProject: Project) -> UIAlertAction {
		return UIAlertAction(title: "Edit", style: .default) { (action) in
			var textField = UITextField()
			
			let alert = UIAlertController(title: "Edit", message: "", preferredStyle: .alert)
			alert.addTextField(configurationHandler: { (editTextField) in
				editTextField.text = selectedProject.name
				textField = editTextField
			})
			
			let action = UIAlertAction(title: "Edit", style: .default, handler: { (action) in
				do {
					if textField.text! != "" {
						try self.realm.write {
							selectedProject.name = textField.text!
						}
						self.update()
					}
				}
				catch {
					print("Error while editing Text, \(error)")
				}
			})
			alert.addAction(action)
			alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
			self.present(alert, animated: true, completion: nil)
		}
	}
	
	
	fileprivate func archivAction(_ selectedProject: Project) -> UIAlertAction {
		return UIAlertAction(title: "Archive", style: .default) { (action) in
			do {
				try self.realm.write {
					selectedProject.archiv = true
					selectedProject.intervals.last?.endDate = Date()
					selectedProject.intervals.last?.running = false
				}
				self.update()
			}
			catch {
				print("Error while archiving project, \(error)")
			}
		}
	}
	
	fileprivate func deleteAction(_ selectedProject: Project) -> UIAlertAction {
		return UIAlertAction(title: "Delete", style: .destructive) { (action) in
			
			let alertToCheck = UIAlertController(title: "Delete", message: "Are You sure you want to delete \(selectedProject.name)", preferredStyle: .alert)
			alertToCheck.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
			alertToCheck.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { (action) in
				do {
					try self.realm.write {
						self.realm.delete(selectedProject)
					}
					self.update()
				}
				catch {
					print("Error while deleting Project, \(error)")
				}
			}))
			
			self.present(alertToCheck, animated: true, completion: nil)
		}
	}
}

extension TableViewController : CanChangeColor {
	func changeColor(to colorChosen: UIColor) {
		color = colorChosen
		update()
	}
}
