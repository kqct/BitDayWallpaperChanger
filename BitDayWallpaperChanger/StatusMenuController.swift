//
//  StatusMenuController.swift
//  BitDayWallpaperChanger
//
//  Created by Josh on 3/16/18.
//  Copyright © 2018 Josh. All rights reserved.
//

import Cocoa

class StatusMenuController: NSObject {
    
    let wallpaperManager = WallpaperManager()
    
    @IBOutlet weak var statusMenu: NSMenu!
    
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    
    override func awakeFromNib() {
        let icon = NSImage(named: NSImage.Name("statusIcon"))
        icon?.isTemplate = true // best for dark mode
        statusItem.image = icon
        statusItem.menu = statusMenu
        
        updateWallpaper()
    }
    
    func updateWallpaper() {
        wallpaperManager.changeBackgroundSwift()
    }
    
    @IBAction func updateClicked(_ sender: NSMenuItem) {
        updateWallpaper()
    }
    
    @IBAction func preferencesClicked(_ sender: NSMenuItem) {
        Bundle.main.loadNibNamed(NSNib.Name(rawValue: "PreferencesWindow"), owner: self, topLevelObjects: nil)
    }
    
    @IBAction func quitClicked(_ sender: NSMenuItem) {
        NSApplication.shared.terminate(self)
    }
}
