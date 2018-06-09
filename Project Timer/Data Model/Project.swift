//
//  Project.swift
//  Project Timer
//
//  Created by Christian Schneeweiss on 10.06.18.
//  Copyright © 2018 Christian Schneeweiss. All rights reserved.
//

import Foundation
import RealmSwift

class Project: Object {
	@objc dynamic var name = ""
	let intervals = List<ProjectTimeInterval>()
}
