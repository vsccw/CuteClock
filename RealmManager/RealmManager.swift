//
//  AlertModel.swift
//  AlertModel
//
//  Created by vsccw on 2017/11/26.
//  Copyright © 2017年 vsccw. All rights reserved.
//

import UIKit
import Realm
import RealmSwift
import RxSwift

public class RealmManager: NSObject {
  
  public static let current = RealmManager()
  
  var realm: Realm?
  
  public override init() {
    super.init()
  }
  
  public func setup(appName: String, _ version: UInt64) throws {
    try setupRealm(appName, version)
  }
  
  func setupRealm(_ appName: String, _ version: UInt64) throws {
    
    guard var path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first else {
      throw NSError(domain: "Error- document directory not found", code: 0, userInfo: nil)
    }
    path.append("/Realm/\(appName)_alert.realm")
    let fileExisted = FileManager.default.fileExists(atPath: path)
    if !fileExisted {
      FileManager.default.createFile(atPath: path, contents: nil, attributes: nil)
    }
    
    let fileURL = URL(fileURLWithPath: path)
    
    var configuration: Realm.Configuration {
      let config = Realm.Configuration(fileURL: fileURL,
                                       schemaVersion: version,
                                       migrationBlock: { (migration, oldVersion) in
                                        if version > oldVersion {
                                          /// handle migration
                                        }
      })
      return config
    }
    
    realm = try Realm(configuration: configuration)
  }
  
  
}

extension RealmManager {
  
  public func allAlert() -> Observable<[Alert]> {
    guard let _alerts = realm?.objects(_Alert.self) else {
      return Observable.empty()
    }
    let alerts = Array(_alerts).map {
      $0.toAlert
    }
    return Observable.just(alerts)
  }
  
  public func addAlert(_ alert: Alert) {
    try? realm?.write {
      realm?.add(alert.to_Alert, update: true)
    }
  }
  
  public func deleteAlert(_ alert: Alert) {
    try? realm?.write {
      realm?.delete(alert.to_Alert)
    }
  }
  
}