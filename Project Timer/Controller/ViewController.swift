//
//  ViewController.swift
//  Project Timer
//
//  Created by Christian Schneeweiss on 08.06.18.
//  Copyright © 2018 Christian Schneeweiss. All rights reserved.
//

import UIKit
import Foundation
import CoreData

class ViewController: UIViewController {

	@IBOutlet weak var currentSessionDuration: UILabel!
	@IBOutlet weak var allTimeDuration: UILabel!
	@IBOutlet weak var startStopButton: UIButton!
	@IBOutlet weak var navigationBar: UINavigationItem!
	
	var timer = Timer()
	
	var selectedProject : Project? {
		didSet{
			load()
		}
	}
	
	var intervals = [ProjectTimeInterval]()
	let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
	
	var timePassedInSeconds : UInt = 0
	var allTimePassedInSeconds : UInt = 0
	var prevDate = Date()
	
	var timerRunning : Bool = false
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		configureTimerAtStart()
		load()		
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	
	func timeToString(hours: UInt, minutes: UInt, seconds: UInt) -> (String,String,String) {
		let hoursString = hours<10 ? "0\(hours)" : String(hours)
		let minutesString = minutes<10 ? "0\(minutes)" : String(minutes)
		let secondsString = seconds<10 ? "0\(seconds)" : String(seconds)
		return (hoursString, minutesString, secondsString)
	}
	
	//MARK: Core Data Manipulation
	
	func save() {
		do {
			try context.save()
		}
		catch {
			print("Error while saving Context, \(error)")
		}
	}
	
	func load() {
		let request : NSFetchRequest<ProjectTimeInterval> = ProjectTimeInterval.fetchRequest()
		let sorting = NSSortDescriptor(key: "startDate", ascending: true)
		request.sortDescriptors = [sorting]
		do {
			intervals = try context.fetch(request)
			if let running = (intervals.last?.running) {
				timerRunning = running
			}
			calculateTime()
			updateAllTimeLabel()
			updateCurrentTimeLabel()
		}
		catch {
			print("Error while fetching intervals, \(error)")
		}
		
	}
	
	
	//MARK: UI Update
	
	func updateCurrentTimeLabel() {
		let (h,m,s) = secondsToHoursMinutesSeconds(seconds: timePassedInSeconds)
		let (hoursString,minutesString,secondsString) = timeToString(hours: h, minutes: m, seconds: s)
		currentSessionDuration.text = "\(hoursString):\(minutesString):\(secondsString)"
	}
	
	func updateAllTimeLabel() {
		let (h,m,s) = secondsToHoursMinutesSeconds(seconds: allTimePassedInSeconds)
		let (hoursString,minutesString,secondsString) = timeToString(hours: h, minutes: m, seconds: s)
		allTimeDuration.text = "\(hoursString):\(minutesString):\(secondsString)"
	}

	//MARK: Calculations
	
	func secondsToHoursMinutesSeconds (seconds : UInt) -> (UInt, UInt, UInt) {
		return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
	}
	
	func calculateTime() {
		allTimePassedInSeconds = 0
		timePassedInSeconds = 0
		for interval in intervals {
			if !interval.running {
				allTimePassedInSeconds += UInt(round((interval.endDate?.timeIntervalSince(interval.startDate!))!))				
			}
		}
		if timerRunning {
			if let startDate = intervals.last?.startDate {
				let currentDate = Date()
				timePassedInSeconds = UInt(round(currentDate.timeIntervalSince(startDate)))
			}
		}
		allTimePassedInSeconds += timePassedInSeconds
	}
	
	//MARK: Timer logic
	
	func configureTimerAtStart() {
		timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (timer) in
			if self.timerRunning {
				let currentDate = Date()
				
				let interval = round(currentDate.timeIntervalSince(self.prevDate))
				self.prevDate = currentDate				
				
				self.timePassedInSeconds += UInt(interval)
				self.allTimePassedInSeconds += UInt(interval)
				self.updateAllTimeLabel()
				self.updateCurrentTimeLabel()
			}
		}
	}
	
	fileprivate func startTimer() {
		let newInterval = ProjectTimeInterval(context: context)
		newInterval.startDate = Date()
		newInterval.running = true
		intervals.append(newInterval)
		prevDate = Date()
		save()
		timePassedInSeconds = 0
		startStopButton.setTitle("Stop", for: .normal)
	}
	
	fileprivate func stopTimer() {
		timePassedInSeconds = 0
		intervals.last?.running = false
		intervals.last?.endDate = Date()
		startStopButton.setTitle("Start", for: .normal)
		save()
	}
	
	@IBAction func startStopButtonPressed(_ sender: UIButton) {
		timerRunning = !timerRunning
		if timerRunning {
			startTimer()
		}
		else {
			stopTimer()
		}
		
		
	}
	
	@IBAction func restartButtonPressed(_ sender: Any) {
		for interval in intervals {
			context.delete(interval)
		}
		save()
		intervals = [ProjectTimeInterval]()
		timerRunning = false
		timePassedInSeconds = 0
		allTimePassedInSeconds = 0
		updateAllTimeLabel()
		updateCurrentTimeLabel()
		startStopButton.setTitle("Start", for: .normal)
		
	}
}

