//
//  File.swift
//  Project Timer
//
//  Created by Christian Schneeweiss on 10.06.18.
//  Copyright © 2018 Christian Schneeweiss. All rights reserved.
//

import Foundation
import RealmSwift

class ProjectTimeInterval : Object {
	@objc dynamic var startDate = Date()
	@objc dynamic var endDate : Date?
	@objc dynamic var desc : String?
	@objc dynamic var running : Bool = false
	var parentProject = LinkingObjects(fromType: Project.self, property: "intervals")
}
