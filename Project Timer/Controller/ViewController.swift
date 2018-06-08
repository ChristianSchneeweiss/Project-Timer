//
//  ViewController.swift
//  Project Timer
//
//  Created by Christian Schneeweiss on 08.06.18.
//  Copyright © 2018 Christian Schneeweiss. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

	@IBOutlet weak var currentSessionDuration: UILabel!
	@IBOutlet weak var allTimeDuration: UILabel!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	@IBAction func startStopButtonPressed(_ sender: UIButton) {
	}
	
}

