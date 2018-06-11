//
//  ArchivTVC.swift
//  Project Timer
//
//  Created by Christian Schneeweiss on 11.06.18.
//  Copyright © 2018 Christian Schneeweiss. All rights reserved.
//

import UIKit
import RealmSwift

class ArchivTVC: UITableViewController {
	
	var projects : Results<Project>?
	let realm = try! Realm()

    override func viewDidLoad() {
        super.viewDidLoad()
		
		tableView.register(UINib(nibName: "ProjectsCell", bundle: nil), forCellReuseIdentifier: "ProjectsCell")
		loadProjects()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return projects?.count ?? 1
    }

	
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProjectsCell", for: indexPath) as! ProjectsCell
		
		let seconds = getProjectDependentInformation(for: projects?[indexPath.row])
		let hourString = seconds/3600 > 10 ? "\(seconds / 3600)" : "0\(seconds / 3600)"
		let minutesString = seconds % 3600 / 60 > 10 ? "\(seconds % 3600 / 60)" : "0\(seconds % 3600 / 60)"
		cell.timeLabel.text = "\(hourString):\(minutesString)"
		
        cell.titleLabel.text = projects?[indexPath.row].name ?? "No Projects Archived"

        return cell
    }

	//MARK: Table View Delegate
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		guard let projectToDelete = projects?[indexPath.row] else { fatalError("Project cant be deleted because it doesnt exist")}
		
		do {
			try realm.write {
				realm.delete(projectToDelete)
			}
			tableView.reloadData()
		}
		catch {
			print("Error while deleting in archive, \(error)")
		}
	}
	

	//MARK: Realm Data Methods
	
	func loadProjects() {
		projects = realm.objects(Project.self).filter("archiv == true")
	}
	
	//MARK: Project Information
	
	func getProjectDependentInformation(for project: Project?) -> UInt {
		if let currentProject = project
		{
			let intervals = currentProject.intervals.sorted(byKeyPath: "startDate", ascending: true)
			var secondsInProject : UInt = 0
			
			for interval in intervals {
				if !interval.running {
					let startDate = interval.startDate
					let endDate = interval.endDate ?? Date()
					secondsInProject += UInt(round(endDate.timeIntervalSince(startDate)))
				}
			}
			return secondsInProject
		}
		return 0
	}

}
