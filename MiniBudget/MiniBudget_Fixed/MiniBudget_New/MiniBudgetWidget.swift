//
//  MiniBudgetWidget.swift
//  MiniBudget_New
//
//  Created by Erandi Pathirana on 2026-05-12.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), totalSaved: 3000, targetAmount: 5000)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let data = WidgetDataManager.shared.getData()
        let entry = SimpleEntry(date: Date(), totalSaved: data.totalSaved, targetAmount: data.targetAmount)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        let currentDate = Date()
        let data = WidgetDataManager.shared.getData()
        
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, totalSaved: data.totalSaved, targetAmount: data.targetAmount)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}


struct SimpleEntry: TimelineEntry {
    let date: Date
    let totalSaved: Double
    let targetAmount: Double
    
    var progress: Double {
        min(totalSaved / targetAmount, 1.0)
    }
}

struct MiniBudgetWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack(alignment: .leading) {
            Text("MiniBudget")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text("Rs. \(Int(entry.totalSaved))")
                .font(.headline)
                .foregroundColor(Color(hex: "#4CAF50"))
            
            Text("Saved of Rs. \(Int(entry.targetAmount))")
                .font(.system(size: 10))
                .foregroundColor(.gray)
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(hex: "#4CAF50"))
                        .frame(width: geo.size.width * CGFloat(entry.progress), height: 8)
                }
            }
            .frame(height: 8)
            .padding(.top, 4)
        }
        .padding()
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

struct MiniBudgetWidget: Widget {
    let kind: String = "MiniBudgetWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            MiniBudgetWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Savings Progress")
        .description("Track your daily savings goal.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}


#Preview(as: .systemSmall) {
    MiniBudgetWidget()
} timeline: {
    SimpleEntry(date: .now, totalSaved: 3000, targetAmount: 5000)
    SimpleEntry(date: .now, totalSaved: 4500, targetAmount: 5000)
}
