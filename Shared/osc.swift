//
//  osc.swift
//  Open-Shop-Channel-Downloader
//
//  Created by Noah Pistilli on 2021-06-15.
//

import Foundation
import SystemConfiguration

struct OSCData: Codable, Identifiable {
    var display_name: String
    var coder: String
    var internal_name: String
    var category: String
    var short_description: String
    var long_description: String
    var zip_size: Int
    var controllers: String
    var zip_url: String
    // ID does not exist in the JSON, as such we assign a value to it
    // in order to make the struct conform to Identifiable
    let id = UUID()
}


let offlineJSON = """
    [
        {
            "category": "utilities",
            "coder": "SketchMaster2001",
            "contributors": "",
            "controllers": "w",
            "display_name": "It would seem that you are not",
            "downloads": 0,
            "extra_directories": [],
            "extracted": 314017,
            "icon_url": "https://hbb1.oscwii.org/hbb/HIDTest.png",
            "internal_name": "HIDTest",
            "long_description": "Nintendont allows you to run GameCube games on a Wii or Wii U from an SD device.",
            "package_type": "dol",
            "rating": "",
            "release_date": 1379566800,
            "shop_title_id": "",
            "shop_title_version": "",
            "short_description": "Gamecube Loader",
            "updated": 1379566800,
            "version": "1.0",
            "zip_size": 172264,
            "zip_url": "https://hbb1.oscwii.org/hbb/HIDTest/HIDTest.zip"
        },
        {
            "category": "utilities",
            "coder": "SketchMaster2001",
            "contributors": "",
            "controllers": "w",
            "display_name": "connected to the internet",
            "downloads": 0,
            "extra_directories": [],
            "extracted": 314017,
            "icon_url": "https://hbb1.oscwii.org/hbb/HIDTest.png",
            "internal_name": "HIDTest",
            "long_description": "Nintendont allows you to run GameCube games on a Wii or Wii U from an SD device.",
            "package_type": "dol",
            "rating": "",
            "release_date": 1379566800,
            "shop_title_id": "",
            "shop_title_version": "",
            "short_description": "Gamecube Loader",
            "updated": 1379566800,
            "version": "1.0",
            "zip_size": 172264,
            "zip_url": "https://hbb1.oscwii.org/hbb/HIDTest/HIDTest.zip"
        }
    ]
"""

class OSCAPI {
    // Display pre-determined JSON if offline
    func offlineData(completion:@escaping ([OSCData]) -> ()) {
        let jsonData = offlineJSON.data(using: .utf8)!
        let offlineData = try! JSONDecoder().decode([OSCData].self, from: jsonData)
        DispatchQueue.main.async {
            completion(offlineData)
        }
    }
    
    // Parse JSON from OSC API
    func getData(completion:@escaping ([OSCData]) -> ()) {
        guard let url = URL(string: "https://api.oscwii.org/v2/primary/packages") else { return }
        URLSession.shared.dataTask(with: url) { (data, _, _) in
            let users = try! JSONDecoder().decode([OSCData].self, from: data!)
            
            DispatchQueue.main.async {
                completion(users)
            }
        }
        .resume()
    }
    
    // Download ZIP from OSC servers
    func getZip(filepath: URL, url: String) {
        if let zipURL = URL(string: url) {
            URLSession.shared.downloadTask(with: zipURL) { (tempFileUrl, response, error) in
                if let zipTempFileUrl = tempFileUrl {
                    do {
                        // Write to file
                        let zipData = try Data(contentsOf: zipTempFileUrl)
                        try zipData.write(to: filepath)
                        
                    } catch {
                        print("Error")
                    }
                }
            }.resume()
        }
    }
    
    // In iOS we will have to pass the app name, as the user cannot choose where
    // or what to save the ZIP under
    func getZipiOS(url: String, app_name: String) {

        let documentDirectory = FileManager.default.urls(for: .documentDirectory,
                                                        in: .userDomainMask)[0]
        print(documentDirectory)
        let imageName = documentDirectory.appendingPathComponent("\(app_name).zip")
        
        if let imageUrl = URL(string: url) {
            URLSession.shared.downloadTask(with: imageUrl) { (tempFileUrl, response, error) in
                if let imageTempFileUrl = tempFileUrl {
                    do {
                        // Write to file
                        let imageData = try Data(contentsOf: imageTempFileUrl)
                        try imageData.write(to: imageName)
                        
                    } catch {
                        print("Error")
                    }
                }
            }.resume()
        }
    }
}

/// From StackOverflow page https://stackoverflow.com/questions/30743408/check-for-internet-connection-with-swift
public class Reachability {

    class func isConnectedToNetwork() -> Bool {

        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)

        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }

        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
            return false
        }

        /* Only Working for WIFI
        let isReachable = flags == .reachable
        let needsConnection = flags == .connectionRequired

        return isReachable && !needsConnection
        */

        // Working for Cellular and WIFI
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        let ret = (isReachable && !needsConnection)

        return ret

    }
}
