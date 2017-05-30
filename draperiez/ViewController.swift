//
//  ViewController.swift
//  draperiez
//
//  Created by Leo Dion on 5/29/17.
//  Copyright © 2017 Leo Dion. All rights reserved.
//

import Cocoa
import ScriptingBridge

class ViewController: NSViewController {
  
  @IBOutlet weak var windowsPopUpButton: NSPopUpButton!
  @IBOutlet weak var sizesPopUpButton: NSPopUpButton!
  
  var windows : [SystemEventsWindow]! = nil
  
  
  @IBAction func placeAction (_ button: NSButton) {
    
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    let application = SBApplication(bundleIdentifier: "com.apple.systemevents")! as SystemEventsApplication
    let processes = application.processes?().flatMap{ $0 as? SystemEventsProcess }
    self.windows = processes?.flatMap{ $0.windows?().flatMap{ $0 as? SystemEventsWindow } }.flatMap{ $0 }
    self.windowsPopUpButton.addItems(withTitles: windows.map{ $0.title ?? $0.name ?? "" })
    
  }
  
  override var representedObject: Any? {
    didSet {
      // Update the view, if already loaded.
    }
  }
  
  
}

