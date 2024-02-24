//
//  Access.swift
//  ChenToolBox
//
//  Created by 陈依澄 on 2023/9/26.
//

import Foundation
import EventKit
import SwiftUI
enum BWPrivacyAuthorizerStatus {
    case notDetermined                  //尚未授权
    case restricted                     //家长控制
    case denied                         //拒绝
    case authorized                     //已授权
}

func bw_calendarAuthorizationStatus() -> BWPrivacyAuthorizerStatus {
    let status = EKEventStore.authorizationStatus(for: EKEntityType.event)
    switch status {
    case .notDetermined:
        return .notDetermined
    case .restricted:
        return .restricted
    case .denied:
        return .denied
    case .authorized:
        return .authorized
    default:
        return .denied
    }
}

class Access:ObservableObject{
    @Published var isShowingSettingsAlert: Bool = false
    @Published var isAuthorized: Bool = false
    func requestCalendarAccess(completion: @escaping (Bool) -> Void){
        switch bw_calendarAuthorizationStatus(){
        case .authorized:
            isAuthorized = true
            completion(true)
            
            
        case .notDetermined:
            let eventStore = AppStatic.eventStore
            if #available(iOS 17.0, *) {
                eventStore.requestFullAccessToEvents { granted, error in
                    DispatchQueue.main.async{
                        if(!granted){
                            self.isShowingSettingsAlert = true
                            self.isAuthorized = false
                            completion(false)
                        }
                        else{
                            self.isAuthorized = true
                            completion(true)
                        }
                    }
                }
                
            } else {
                // Fallback on earlier versions
                eventStore.requestAccess(to: .event) { granted, error in
                    DispatchQueue.main.async{
                        if(!granted){
                            self.isShowingSettingsAlert = true
                            self.isAuthorized = false
                            completion(false)
                        }else{
                            self.isAuthorized = true
                            completion(true)
                        }
                    }
                }
            }
            
            
        default:
            DispatchQueue.main.async{
                self.isShowingSettingsAlert = true
                self.isAuthorized = false
                completion(false)
            }
        }
    }
    
    func showAlert(accessObject: String) -> Alert{
        return Alert(
            title: Text("无法访问\(accessObject)"),
            message: Text("请在设备的\"设置-隐私-\(accessObject)\"中允许\(AppStatic.appName)访问\(accessObject)"),
            primaryButton: .default(Text("Settings"), action: openSettings),
                            secondaryButton: .cancel()
        )
    }
    
    func openSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl)
        }
    }
}

