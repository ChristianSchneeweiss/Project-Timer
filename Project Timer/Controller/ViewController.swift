//
//  ViewController.swift
//  Project Timer
//
//  Created by Christian Schneeweiss on 08.06.18.
//  Copyright © 2018 Christian Schneeweiss. All rights reserved.
//

import UIKit
import Foundation

class ViewController: UIViewController {

	@IBOutlet weak var currentSessionDuration: UILabel!
	@IBOutlet weak var allTimeDuration: UILabel!
	@IBOutlet weak var startStopButton: UIButton!
	@IBOutlet weak var navigationBar: UINavigationItem!
	
	var timer = Timer()
	
	var timePassedInSeconds : UInt = 0
	var allTimePassedInSeconds : UInt = 0
	var startDate = Date()
	var prevDate = Date()
	
	var seconds : UInt = 0
	var minutes : UInt = 0
	var hours : UInt = 0
	
	var timerRunning : Bool = false
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		configureTimerAtStart()
		navigationBar.title = "HelloWorld"
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
	
	
	//MARK: UI Update
	
	func updateCurrentTimeLabel() {
		caluclateCurrentPassedTime()
		let (hoursString,minutesString,secondsString) = timeToString(hours: hours, minutes: minutes, seconds: seconds)
		currentSessionDuration.text = "\(hoursString):\(minutesString):\(secondsString)"
	}
	
	func updateAllTimeLabel() {
		let (h,m,s) = secondsToHoursMinutesSeconds(seconds: allTimePassedInSeconds)
		let (hoursString,minutesString,secondsString) = timeToString(hours: h, minutes: m, seconds: s)
		allTimeDuration.text = "\(hoursString):\(minutesString):\(secondsString)"
	}

	//MARK: Calculations
	
	func caluclateCurrentPassedTime() {
		(hours,minutes,seconds) = secondsToHoursMinutesSeconds(seconds: timePassedInSeconds)
	}
	
	func secondsToHoursMinutesSeconds (seconds : UInt) -> (UInt, UInt, UInt) {
		return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
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
	
	@IBAction func startStopButtonPressed(_ sender: UIButton) {
		timerRunning = !timerRunning
		if timerRunning {
			startDate = Date()
			prevDate = startDate
			startStopButton.setTitle("Stop", for: .normal)
		}
		else {
			timePassedInSeconds = 0
			startStopButton.setTitle("Start", for: .normal)
		}
		
		
	}
	
	@IBAction func restartButtonPressed(_ sender: Any) {
		timerRunning = false
		timePassedInSeconds = 0
		allTimePassedInSeconds = 0
		updateAllTimeLabel()
		updateCurrentTimeLabel()
		startStopButton.setTitle("Start", for: .normal)		
	}
}

