//
//  ViewController.swift
//  Project Timer
//
//  Created by Christian Schneeweiss on 08.06.18.
//  Copyright © 2018 Christian Schneeweiss. All rights reserved.
//

import UIKit
import Foundation
import RealmSwift

protocol CanBeUpdated {
	func update()
}

class ViewController: UIViewController {

	@IBOutlet weak var currentSessionDuration: UILabel!
	@IBOutlet weak var allTimeDuration: UILabel!
	@IBOutlet weak var startStopButton: UIButton!
	@IBOutlet weak var navigationBar: UINavigationItem! // TODO: better code
	
	var delegate : CanBeUpdated?
	
	var timer = Timer()
	let realm = try! Realm()
	var bColor : UIColor?
	
	var selectedProject : Project? {
		didSet{
			load()
		}
	}
	
	var intervals : Results<ProjectTimeInterval>?
	
	var timePassedInSeconds : UInt = 0
	var allTimePassedInSeconds : UInt = 0
	var prevDate = Date()
	
	var timerRunning : Bool = false
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		configureTimerAtStart()
		
		navigationBar.title = selectedProject?.name ?? "no Title"
		preparationForView()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		view.backgroundColor = bColor
		let contrastColor = UIColor(contrastingBlackOrWhiteColorOn: bColor, isFlat: true)
		allTimeDuration.textColor = contrastColor
		currentSessionDuration.textColor = contrastColor
	}
	
	
	override func viewWillDisappear(_ animated: Bool) {
		delegate?.update()
	}
	
	func timeToString(hours: UInt, minutes: UInt, seconds: UInt) -> (String,String,String) {
		let hoursString = hours<10 ? "0\(hours)" : String(hours)
		let minutesString = minutes<10 ? "0\(minutes)" : String(minutes)
		let secondsString = seconds<10 ? "0\(seconds)" : String(seconds)
		return (hoursString, minutesString, secondsString)
	}
	
	//MARK: Core Data Manipulation
	
	func load() {
		intervals = selectedProject?.intervals.sorted(byKeyPath: "startDate", ascending: true)
	}
	
	func preparationForView() {
		if let running = (intervals?.last?.running) {
			timerRunning = running
			let buttonTitle = timerRunning ? "Stop" : "Start"
			startStopButton.setTitle(buttonTitle, for: .normal)
		}
		calculateTime()
		updateAllTimeLabel()
		updateCurrentTimeLabel()
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
		if let timeIntervals = intervals {
			for interval in timeIntervals {
				if !interval.running {
					allTimePassedInSeconds += UInt(round((interval.endDate?.timeIntervalSince(interval.startDate))!))
				}
			}
		}
		if timerRunning {
			if let startDate = intervals?.last?.startDate {
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
		
		do {
			try self.realm.write() {
				let newInterval = ProjectTimeInterval()
				newInterval.startDate = Date()
				newInterval.running = true
				selectedProject?.intervals.append(newInterval)
			}
		}
		catch {
			print("Error while saving intervals, \(error)")
		}
		prevDate = Date()
		timePassedInSeconds = 0
		startStopButton.setTitle("Stop", for: .normal)
	}
	
	fileprivate func stopTimer() {
		timePassedInSeconds = 0
		
		do {
			try realm.write() {
				intervals?.last?.running = false
				intervals?.last?.endDate = Date()
			}
		}
		catch {
			print("Error while stoping and writing to the realm, \(error)")
		}
		startStopButton.setTitle("Start", for: .normal)
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
		if let timeIntervals = intervals {
			for interval in timeIntervals {
				do {
					try realm.write {
						realm.delete(interval)
					}
				}
				catch {
					print("Error while restarting and deleting, \(error)")
				}
			}
		}
		timerRunning = false
		timePassedInSeconds = 0
		allTimePassedInSeconds = 0
		updateAllTimeLabel()
		updateCurrentTimeLabel()
		startStopButton.setTitle("Start", for: .normal)
		
	}
}

