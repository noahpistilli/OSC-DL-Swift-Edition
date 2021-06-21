//
//  osc.swift
//  Open Shop Channel Downloader
//
//  Created by Noah Pistilli on 2021-06-15.
//

import Foundation

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
}
