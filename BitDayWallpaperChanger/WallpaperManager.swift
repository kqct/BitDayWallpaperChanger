//
//  WallpaperManager.swift
//  BitDayWallpaperChanger
//
//  Created by Josh on 3/16/18.
//  Copyright © 2018 Josh. All rights reserved.
//

import Foundation
import Cocoa
import SQLite

class WallpaperManager {
    let hour = Calendar.current.component(.hour, from: Date())
    
    let startHour = 4
    let hourIncrement = 2
    let imgDirectory = URL(fileURLWithPath: "~/Pictures/PictureSets/BitDay/", isDirectory: true)
    
    func getIdFromNumber(currentHour: Int, startHour: Int, hourIncrement: Int) -> Int {
        return (((currentHour < startHour ? currentHour + 24 : currentHour) - startHour) / hourIncrement) + 1
    }
    
    func getFirstFileNameURLStringContainingString(directory: URL, str: String) -> URL {
        // let defaultWallpaper = URL(fileURLWithPath: "/Library/Desktop Pictures/Abstract.jpg")
        let defaultWallpaper = URL(fileURLWithPath: "/System/Library/CoreServices/DefaultDesktop.jpg")
        do {
            let directoryContents = try FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil, options: FileManager.DirectoryEnumerationOptions.skipsHiddenFiles)
            let matchingFiles = directoryContents.filter{$0.lastPathComponent.contains(str);}
            if let first = matchingFiles.first {
                return first
            } else {
                NSLog("No files exist with filenames containing \(str)! Using default wallpaper instead")
            }
            return defaultWallpaper
        } catch {
            NSLog("Directory read error: \(error)")
            NSLog("Couldn't get contents of directory! Using default wallpaper instead")
        }
        return defaultWallpaper
    }
    
    func shell(launchPath: String, args: [String]) {
        let task = Process()
        task.launchPath = launchPath
        task.arguments = args

        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe

        task.launch()
        task.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output: String = String(data: data, encoding: String.Encoding.utf8)!
        print(output)
    }
    
    func changeBackgroundSwift() {
        do {
            let workspace = NSWorkspace.shared
            let screens = NSScreen.screens
            let imageUrl = getFirstFileNameURLStringContainingString(directory: imgDirectory,
                    str: String(getIdFromNumber(currentHour: hour, startHour: startHour, hourIncrement: hourIncrement)))
            NSLog("Setting wallpaper...")
            for screen in screens {
                try workspace.setDesktopImageURL(imageUrl, for: screen, options: [:])
            }
            NSLog("Wallpaper set!")
        } catch {
            NSLog("Error setting wallpaper: \(error)")
        }
    }
    
    func changeBackgroundSQL() {
        let imageUrl = getFirstFileNameURLStringContainingString(
                directory: imgDirectory,
                str: String(getIdFromNumber(currentHour: hour, startHour: 5, hourIncrement: 2)))

        let path = NSSearchPathForDirectoriesInDomains(
                .applicationSupportDirectory, .userDomainMask, true
        ).first! + "/Dock"

        do {
            let db = try Connection("\(path)/desktoppicture.db")

            let data = Table("data")
            let value = Expression<String>("value")

            do {
                if try db.run(data.update(value <- imageUrl.absoluteString)) > 0 {
                    shell(launchPath: "/usr/bin/killall", args: ["Dock"])
                    NSLog("Successfully updated data")
                } else {
                    NSLog("Couldn't update table!")
                }
            } catch {
                NSLog("Update failed: \(error)")
            }

        } catch {
            NSLog("Error connecting to desktop database: \(error)")
        }
    }
}
