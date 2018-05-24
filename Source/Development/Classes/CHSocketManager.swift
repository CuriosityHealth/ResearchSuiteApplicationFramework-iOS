//
//  CHSocketManager.swift
//  ResearchSuiteApplicationFramework
//
//  Created by James Kizer on 4/14/18.
//
//  Copyright Curiosity Health Company. All rights reserved.
//

import UIKit
import Starscream
import Gloss
import ReSwift

struct FileUpdateMessage: Gloss.JSONDecodable {
    
    let filename: String!
    let type: String!
    
    // MARK: - Deserialization
    
    init?(json: JSON) {
        guard let filename: String = "filename" <~~ json,
            let type: String = "type" <~~ json
            else {
                return nil
        }
        
        self.filename = filename
        self.type = type
    }
    
}

struct LoadActivityMessage: Gloss.JSONDecodable {
    
    let activity: String!
    let type: String!
    
    // MARK: - Deserialization
    
    init?(json: JSON) {
        guard let activity: String = "activity" <~~ json,
            let type: String = "type" <~~ json
            else {
                return nil
        }
        
        self.activity = activity
        self.type = type
    }
    
}


import UIKit
import ReSwift
import ResearchSuiteResultsProcessor

open class CHSocketManager: NSObject, WebSocketDelegate, RSActionManagerDelegate, StoreSubscriber, RSRoutingDelegate {
    
    let socket: WebSocket
    weak var store: Store<RSState>?
    
    var state: RSState?
    open var onConnectCallback: ((CHSocketManager) -> ())?
    
    public init(socketServerURL: URL, store: Store<RSState>) {
        
        self.socket = WebSocket(url: socketServerURL)
        self.store = store
        super.init()
        self.socket.delegate = self
        self.socket.connect()
        
        self.store?.subscribe(self)
    }
    
    deinit {
        self.store?.unsubscribe(self)
    }
    
    open func websocketDidConnect(socket: WebSocket) {
        print("websocket is connected")
        //launch
        //        self.store.dispatch(RSActionCreators.queueActivity(activityID: "devActivity"))
        
        self.onConnectCallback?(self)
    }
    
    open func websocketDidDisconnect(socket: WebSocket, error: NSError?) {
        print("websocket is disconnected: \(error?.localizedDescription)")
        //        self.store.dispatch(RSActionCreators.forceDismissActivity(flushActivityQueue: true))
        
    }
    
    private func valueChanged<T: Equatable>(selector: (RSState) -> T?, state: RSState, lastState: RSState) -> Bool {

        if let currentValue = selector(state) {
            
            guard let lastValue = selector(lastState) else {
                return true
            }
            
            return currentValue != lastValue
            
        }
        else {
            return selector(lastState) != nil
        }
        
        
    }
    
    open func newState(state: RSState) {
        
        defer {
            self.state = state
        }
        
        
        guard let lastState = self.state else {
            return
        }
        
        //check for change in displayed activity
        let presentedActivitySelector: (RSState) -> UUID? = { state in
            if let activity = RSStateSelectors.presentedActivity(state) {
                return activity.0
            }
            else {
                return nil
            }
        }
        
        if self.valueChanged(selector: presentedActivitySelector, state: state, lastState: lastState) {
        
            
            let currentActivity: (UUID, String, Date)? = RSStateSelectors.presentedActivity(state)
            let message: JSON = [
                "type": "currentActivity",
                "message": [
                    "identifier": currentActivity?.1
                ]
            ]
            
            if let data = try? JSONSerialization.data(withJSONObject: message, options: [.prettyPrinted]) {
                debugPrint(message)
                self.socket.write(data: data) {
                    
                }
            }
        
        }
        
        
        
        
        
    }
    
    public func logAction(actionLog: RSApplicationActionLog) {
        
        
//        let data = JSONEncoder.
        
        if let log = actionLog.toJSON() {
            
            let message: JSON = [
                "type": "actionLog",
                "message": log
            ]
            
            if let data = try? JSONSerialization.data(withJSONObject: message, options: [.prettyPrinted]) {
                debugPrint(log)
                self.socket.write(data: data) {
                    
                }
            }
        }
        
    }
    
    public func logRoutingEvent(routingEventLog: RSRoutingEventLog) {
        
        if let log = routingEventLog.toJSON() {
            
            let message: JSON = [
                "type": "routingEventLog",
                "message": log
            ]
            
            if let data = try? JSONSerialization.data(withJSONObject: message, options: [.prettyPrinted]) {
//                debugPrint(log)
                self.socket.write(data: data) {
                    
                }
            }
            
        }
        
    }
    
    public func setApplicationLogDirectory(logDirectory: String) {
        
        let message: JSON = [
            "type": "setApplicationLogDirectory",
            "logDirectory": logDirectory
        ]
        
        if let data = try? JSONSerialization.data(withJSONObject: message, options: [.prettyPrinted]) {
            //                debugPrint(log)
            self.socket.write(data: data) {
                
            }
        }
        
    }
    
    public func setDataseFile(databaseFile: String) {
        
        let message: JSON = [
            "type": "setDatabaseFile",
            "file": databaseFile
        ]
        
        if let data = try? JSONSerialization.data(withJSONObject: message, options: [.prettyPrinted]) {
            //                debugPrint(log)
            self.socket.write(data: data) {
                
            }
        }
        
    }
    
    open func websocketDidReceiveMessage(socket: WebSocket, text: String) {
        print("got some text: \(text)")
        
        guard let statusJson = (try? JSONSerialization.jsonObject(with: text.data(using: String.Encoding.utf8)!, options: .allowFragments)) as? JSON,
            let type: String = "type" <~~ statusJson else {
                print("decoding failed")
                return
        }
        
        if type == "action",
            let action: JSON = "action" <~~ statusJson,
            let store = self.store {
            
            store.processAction(action: action, context: [:], store: store)
            
        }
            
        else if type == "reloadLayouts",
            let state = self.store?.state,
            let currentPath = RSStateSelectors.currentPath(state) {
            
            RSApplicationDelegate.appDelegate.loadLayouts()
            let action = RSActionCreators.requestPathChange(path: currentPath, forceReroute: true)
            self.store?.dispatch(action)
            
        }
            
        else if type == "reloadState",
            let state = self.store?.state {
            RSApplicationDelegate.appDelegate.loadState()
            
            let reloadTesting = RSStateSelectors.getValueInCombinedState(state, for: "reloadTesting")
            debugPrint(reloadTesting)
            
            
        }
        
        else if type == "reloadActivities",
            let state = self.store?.state {
            
            self.store?.dispatch(RSActionCreators.forceDismissActivity(flushActivityQueue: true))
            RSApplicationDelegate.appDelegate.loadMeasures()
            RSApplicationDelegate.appDelegate.loadActivities()
            
        }
        
        //        else if  let message = LoadActivityMessage(json: statusJson) {
        //
        //            print("decoding worked!! \n\(message)")
        //            if message.type == "loadActivity" {
        //                //            print("updated \(statusMessage.filename)")
        //                self.store?.dispatch(RSActionCreators.forceDismissActivity(flushActivityQueue: true))
        //                self.store?.dispatch(RSActionCreators.queueActivity(activityID: message.activity))
        //            }
        //
        //        }
        
        
        
    }
    
    open func websocketDidReceiveData(socket: WebSocket, data: Data) {
        print("got some data: \(data.count)")
    }
    
}
