//
//  wiiload.swift
//  Open Shop Channel Downloader
//
//  Created by Noah Pistilli on 2021-06-17.
//

import Foundation
import ZIPFoundation
import Socket
import BinUtils

class WiiLoad {
    public var CHUNK_SIZE = 1024 * 128
    // Regex to validate IPv4 Address. As the Wii does not support IPv6, I do not check.
    let regex = try! NSRegularExpression(pattern: #"^(?:[0-9]{1,3}\.){3}[0-9]{1,3}$"#)
    
    func validateIP(ip: String) -> Bool {
        let range = NSRange(location: 0, length: ip.utf16.count)
        
        if regex.firstMatch(in: ip, options: [], range: range) != nil {
            return true
        } else {
            return false
        }
    }
    
    func fixZIP(zipPath: URL, app_name: String) {
        let fileManager = FileManager()
        let currentWorkingPath = fileManager.currentDirectoryPath
        var destinationURL = URL(fileURLWithPath: currentWorkingPath)
        destinationURL.appendPathComponent("osc-temp")
        do {
            // Unzip then zip into the folder structure HBC wants
            try fileManager.createDirectory(at: destinationURL, withIntermediateDirectories: true, attributes: nil)
            try fileManager.unzipItem(at: zipPath, to: destinationURL)
            
            destinationURL.appendPathComponent("apps/\(app_name)")
            let newZIP = destinationURL.appendingPathComponent("app.zip")
            try fileManager.zipItem(at: destinationURL, to: newZIP)
            
            // For some reason, ZIP Foundation includes the ZIP inside the ZIP.
            // We must take it out or it will double the filesize.
            guard let archive = Archive(url: newZIP, accessMode: .update) else  {
                return
            }
            guard let entry = archive["\(app_name)/app.zip"] else {
                return
            }
            do {
                try archive.remove(entry)
            } catch {
                print("Removing entry from ZIP archive failed with error:\(error)")
            }
        } catch {
            print("Extraction of ZIP archive failed with error:\(error)")
        }
        
    }
    
    func connect() {
        do {
            let client = try Socket.create()
            let startTime = Date()
            try client.connect(to: "192.168.2.44", port: 4299)
            print(Date().timeIntervalSince(startTime))
            
            try client.write(from: "HAXX".data(using: String.Encoding.utf8)!)
            try client.write(from: pack("=B", [0]))
            try client.write(from: pack("=B", [5]))
            try client.write(from: pack(">H", [0]))
            try client.write(from: pack(">L", [100000]))
            try client.write(from: pack(">L", [1000]))
        }
        catch {
            print("Error.")
        }
    }
}
