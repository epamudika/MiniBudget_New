//
//  WidgetDataManager.swift
//  MiniBudget_New
//
//  Created by Erandi Pathirana on 2026-05-12.
//
import Foundation
import WidgetKit

class WidgetDataManager {
    static let shared = WidgetDataManager()
    
    // Use your App Group ID here 
    private let suiteName = "group.com.minibudget.shared"
    
    func saveData(totalSaved: Double, targetAmount: Double) {
        if let defaults = UserDefaults(suiteName: suiteName) {
            defaults.set(totalSaved, forKey: "totalSaved")
            defaults.set(targetAmount, forKey: "targetAmount")
            defaults.synchronize()
            
            // Reload widget timeline
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
    
    func getData() -> (totalSaved: Double, targetAmount: Double) {
        let defaults = UserDefaults(suiteName: suiteName)
        let saved = defaults?.double(forKey: "totalSaved") ?? 0
        let target = defaults?.double(forKey: "targetAmount") ?? 5000
        return (saved, target)
    }
}
