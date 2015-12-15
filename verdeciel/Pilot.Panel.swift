//  Created by Devine Lu Linvega on 2015-07-07.
//  Copyright (c) 2015 XXIIVV. All rights reserved.

import UIKit
import QuartzCore
import SceneKit
import Foundation

class PanelPilot : Panel
{
	var target:Location!
	var targetDirection = CGFloat()
	var targetDirectionIndicator = SCNNode()
	var activeDirectionIndicator = SCNNode()
	var staticDirectionIndicator = SCNNode()
	var eventsDirectionIndicator = SCNNode()
	
	override func setup()
	{
		name = "pilot"
		
		targetDirectionIndicator = SCNNode()
		targetDirectionIndicator.addChildNode(SCNLine(nodeA: SCNVector3(0, 0.55, 0), nodeB: SCNVector3(0, 0.7, 0), color: white))
		interface.addChildNode(targetDirectionIndicator)
		
		activeDirectionIndicator = SCNNode()
		activeDirectionIndicator.addChildNode(SCNLine(nodeA: SCNVector3(0, 0.4, -0.1), nodeB: SCNVector3(0, 0.55, -0), color: grey))
		interface.addChildNode(activeDirectionIndicator)
		
		staticDirectionIndicator = SCNNode()
		staticDirectionIndicator.addChildNode(SCNLine(nodeA: SCNVector3(0, 0.2, -0.1), nodeB: SCNVector3(0, 0.4, -0), color: cyan))
		staticDirectionIndicator.addChildNode(SCNLine(nodeA: SCNVector3(0, -0.2, -0.1), nodeB: SCNVector3(0, -0.4, -0), color: red))
		staticDirectionIndicator.addChildNode(SCNLine(nodeA: SCNVector3(0.2, 0, -0.1), nodeB: SCNVector3(0.4, 0, -0), color: red))
		staticDirectionIndicator.addChildNode(SCNLine(nodeA: SCNVector3(-0.2, 0, -0.1), nodeB: SCNVector3(-0.4, 0, -0), color: red))
		interface.addChildNode(staticDirectionIndicator)
		
		eventsDirectionIndicator = SCNNode()
		eventsDirectionIndicator.addChildNode(SCNLine(nodeA: SCNVector3(0, 0.2, -0.1), nodeB: SCNVector3(0.2, 0, -0), color: white))
		eventsDirectionIndicator.addChildNode(SCNLine(nodeA: SCNVector3(0, 0.2, -0.1), nodeB: SCNVector3(-0.2, 0, -0), color: white))
		interface.addChildNode(eventsDirectionIndicator)
		
		port.input = eventTypes.location
		port.output = eventTypes.unknown
	}
	
	override func start()
	{
		decals.opacity = 0
		interface.opacity = 0
		label.update("--", color: grey)
	}
	
	override func touch(id:Int = 0)
	{
		
	}
	
	override func listen(event: Event)
	{
		target = event as! Location
	}
	
	override func installedFixedUpdate()
	{
		// Approaching the sun
		if capsule.closestLocationOfType(locationTypes.star).distance < 0.25 {
			target = capsule.closestKnownLocation()
			radar.addTarget(target)
			ui.addWarning("radiations")
		}
		else if capsule.closestKnownLocation().distance > 1.45 && capsule.isWarping == false {
			target = capsule.closestKnownLocation()
			radar.addTarget(target)
		}
		else if port.isReceivingType(eventTypes.location) {
			target = port.origin.event as! Location
			radar.addTarget(target)
		}
		else if capsule.dock != nil && capsule.at != capsule.dock.at {
			target = capsule.dock
		}
		else{
			target = nil
		}
		
		if target == nil { return }
		
		let left = target.calculateAlignment(capsule.direction - 0.5)
		let right = target.calculateAlignment(capsule.direction + 0.5)
		
		if target.align >= 0 {
			if left <= right {
				self.turnLeft(target.align * 0.025)
			}
			else if left > right {
				self.turnRight(target.align * 0.025)
			}
		}
		
		if target.align > 25 { details.update(String(format: "%.0f",target.align), color:red) }
		else if target.align < 1 { details.update("ok", color:cyan) }
		else{ details.update(String(format: "%.0f",target.align), color:white) }
		
		
		let targetDirectionNormal = Double(Float(targetDirection)/180) * 1
		targetDirectionIndicator.rotation = SCNVector4Make(0, 0, 1, Float(M_PI * targetDirectionNormal))
		let staticDirectionNormal = Double(Float(capsule.direction)/180) * 1
		staticDirectionIndicator.rotation = SCNVector4Make(0, 0, 1, Float(M_PI * staticDirectionNormal))
		let eventsDirectionNormal = Double(Float(targetDirection - capsule.direction)/180) * 1
		eventsDirectionIndicator.rotation = SCNVector4Make(0, 0, 1, Float(M_PI * eventsDirectionNormal))
	}
	
	
	func turnLeft(deg:CGFloat)
	{
		capsule.direction = capsule.direction - deg
		capsule.direction = capsule.direction % 360
	}
	
	func turnRight(deg:CGFloat)
	{
		capsule.direction = capsule.direction + deg
		capsule.direction = capsule.direction % 360
	}
	
	override func onInstallationBegin()
	{
		ui.addWarning("Installing", duration: 3)
		player.lookAt(deg: -135)
	}
}