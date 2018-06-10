//
//  ColorPopUp.swift
//  Project Timer
//
//  Created by Christian Schneeweiss on 10.06.18.
//  Copyright © 2018 Christian Schneeweiss. All rights reserved.
//

import UIKit
import ChameleonFramework

protocol CanChangeColor {
	func changeColor(to colorChosen : UIColor)
}

class ColorPopUp: UIViewController {
	
	var pickedColor = UIColor.flatSkyBlue()
	var delegate : CanChangeColor?
	
	@IBOutlet var buttons: [UIButton]!
	let colors = [UIColor.flatRed(), UIColor.flatOrange(), UIColor.flatYellow(), UIColor.flatSand(), UIColor.flatPink(), UIColor.flatSkyBlue(), UIColor.flatForestGreen(), UIColor.flatMagentaColorDark(), UIColor.flatMaroon(), UIColor.flatBrown()]
	override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
	
	override func viewWillAppear(_ animated: Bool) {
		colorButtons()
	}
	
	func colorButtons() {
		var counter = 0
		for button in buttons {
			button.backgroundColor = colors[counter]
			counter += 1
		}
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

	@IBAction func buttonPressed(_ sender: UIButton) {
		pickedColor = colors[sender.tag-1]
		delegate?.changeColor(to: pickedColor!)
		dismiss(animated: true, completion: nil)
	}
}
