//
//  AppDelegate.swift
//  Project Timer
//
//  Created by Christian Schneeweiss on 08.06.18.
//  Copyright © 2018 Christian Schneeweiss. All rights reserved.
//

import UIKit
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?


	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		// Override point for customization after application launch.
		
		do {
			_ = try Realm()
		}
		catch {
			print("Error creating Realm, \(error)")
		}
		return true
	}

}

