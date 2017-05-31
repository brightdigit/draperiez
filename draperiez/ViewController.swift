//
//  ViewController.swift
//  draperiez
//
//  Created by Leo Dion on 5/29/17.
//  Copyright © 2017 Leo Dion. All rights reserved.
//

import Cocoa
import ScriptingBridge

extension Collection {
  func toDictionary<K, V>
    (_ transform:(_ element: Self.Generator.Element) -> (key: K, value: V)?) -> [K : V] {
    
    return self.reduce([:]) { ( dictionary, e) in
      var dictionary = dictionary
      if let (key, value) = transform(e){
        dictionary[key] = value
      }
      return dictionary
    }
  }
}

struct SystemEventsProcessWindow {
 let window: SystemEventsWindow
  let process: SystemEventsProcess
}

extension SystemEventsProcessWindow {
  var name : String {
    return self.window.title ?? self.window.name ?? self.process.title ?? self.process.displayedName ?? self.window.description
  }
}

public protocol WindowSize {
  var label : String { get }
  var size : CGSize { get }
}

extension WindowSize {

  func multiply(byRatio ratio: WindowSize) -> WindowSize {
    return CGSize(width: self.size.width * ratio.size.width, height: self.size.height * ratio.size.height)

  }
}


public struct RatioWindowSize : WindowSize {
  let original : WindowSize
  let ratio : WindowSize
  let extraLabel : String
  
  public var label: String {
    return "\(self.extraLabel) : \(self.size)"
  }
  
  public var size : CGSize {
    return self.original.multiply(byRatio: self.ratio).size
  }
}


extension CGSize : WindowSize {
  public var size: CGSize {
    return self
  }

  public var label: String {
    return "\(self.width) x \(self.height)"
  }

  
}

extension CGSize {
  func fitsWithin (_ other: CGSize) -> Bool {
      return self.width <= other.width && self.height <= other.height
  }
}

class ViewController: NSViewController {
  
  @IBOutlet weak var windowsPopUpButton: NSPopUpButton!
  @IBOutlet weak var sizesPopUpButton: NSPopUpButton!
  
  var windows : [String: SystemEventsProcessWindow]! = nil
  var sizes : [String : WindowSize]! = nil
  
  public static let builtInSizes : [CGSize] = [
    CGSize(width: 1920, height: 1080),
    CGSize(width: 1366, height: 768),
    CGSize(width: 1280, height: 720)
  ]
  
  public static let sizeRatios = [
    "Full Screen" : CGSize(width: 1, height: 1),
    "Half of Height" : CGSize(width: 1, height: 0.5),
    "Half of Width" : CGSize(width: 0.5, height: 1),
    "Quarter of Screen" : CGSize(width: 0.5, height: 0.5),
    "Third of Width" : CGSize(width: 1/3.0, height: 1)
  ]
  
  @IBAction func placeAction (_ button: NSButton) {
    
  }
  
  @IBAction func applyAction (_ button: NSButton) {
    let window = self.windows[self.windowsPopUpButton.selectedItem!.title]!
    let size = self.sizes[self.sizesPopUpButton.selectedItem!.title]!
    
    let position = window.window.position
    //debugPrint(position)
    let rect = NSRect(origin: CGPoint(x: 0, y: 0), size: size.size)
    window.window.setBounds!(rect)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    let application = SBApplication(bundleIdentifier: "com.apple.systemevents")! as SystemEventsApplication
    let processes = application.processes?().flatMap{ $0 as? SystemEventsProcess }
    self.windows = processes?.flatMap({ (process) -> [SystemEventsProcessWindow]? in
      return (process.windows?().flatMap({ (window) -> SystemEventsProcessWindow? in
        guard let window = window as? SystemEventsWindow else {
          return nil
        }
        
        return SystemEventsProcessWindow(window: window, process: process)
      }))
    }).flatMap{$0}.toDictionary{ (key: $0.name, value: $0) }
    let size = NSScreen.main()!.frame.size
    self.windowsPopUpButton.removeAllItems()
    self.windowsPopUpButton.addItems(withTitles: [String](self.windows.keys))
    
    self.sizes = [ViewController.builtInSizes, ViewController.sizeRatios.flatMap{
      pair -> WindowSize in
      return RatioWindowSize(original: size, ratio: pair.value, extraLabel: pair.key)
      }].flatMap{$0}.filter{
        $0.size.fitsWithin(size)
      }.toDictionary{(key: $0.label, value: $0)}
    self.sizesPopUpButton.removeAllItems()
    self.sizesPopUpButton.addItems(withTitles: [String](self.sizes.keys))
    
    self.sizesPopUpButton.selectItem(at: 0)
    self.windowsPopUpButton.selectItem(at: 0)
  
  }
  
  override var representedObject: Any? {
    didSet {
      // Update the view, if already loaded.
    }
  }
  
  
}

