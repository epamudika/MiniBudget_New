//
//  PersistenceController.swift
//  MiniBudget_New
//
//  Created by Erandi Pathirana on 2026-05-09.
//
import CoreData
import Foundation

//  Persistence Controller
final class PersistenceController {

    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        let context = controller.container.viewContext

        let goal = UserGoalEntity(context: context)
        goal.id = UUID()
        goal.dailyAmount = 50
        goal.targetAmount = 5000
        goal.currentStreak = 12
        goal.longestStreak = 15
        goal.startDate = Date()

        for i in 0..<7 {
            let entry = SavingEntryEntity(context: context)
            entry.id = UUID()
            entry.date = Calendar.current.date(byAdding: .day, value: -i, to: Date()) ?? Date()
            entry.amount = 50
            entry.streakDay = Int32(12 - i)
        }

        BadgeEntity.seedAll(in: context)

        try? context.save()
        return controller
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        // Build the model programmatically to avoid dependency on .xcdatamodeld files
        let model = NSManagedObjectModel()

        //  UserGoalEntity
        let userGoalEntity = NSEntityDescription()
        userGoalEntity.name = "UserGoalEntity"
        userGoalEntity.managedObjectClassName = NSStringFromClass(UserGoalEntity.self)

        let goalId = NSAttributeDescription()
        goalId.name = "id"; goalId.attributeType = .UUIDAttributeType; goalId.isOptional = false
        let dailyAmount = NSAttributeDescription()
        dailyAmount.name = "dailyAmount"; dailyAmount.attributeType = .doubleAttributeType; dailyAmount.defaultValue = 0.0
        let targetAmount = NSAttributeDescription()
        targetAmount.name = "targetAmount"; targetAmount.attributeType = .doubleAttributeType; targetAmount.defaultValue = 0.0
        let currentStreak = NSAttributeDescription()
        currentStreak.name = "currentStreak"; currentStreak.attributeType = .integer32AttributeType; currentStreak.defaultValue = 0
        let longestStreak = NSAttributeDescription()
        longestStreak.name = "longestStreak"; longestStreak.attributeType = .integer32AttributeType; longestStreak.defaultValue = 0
        let startDate = NSAttributeDescription()
        startDate.name = "startDate"; startDate.attributeType = .dateAttributeType; startDate.isOptional = true

        userGoalEntity.properties = [goalId, dailyAmount, targetAmount, currentStreak, longestStreak, startDate]

        // SavingEntryEntity
        let savingEntryEntity = NSEntityDescription()
        savingEntryEntity.name = "SavingEntryEntity"
        savingEntryEntity.managedObjectClassName = NSStringFromClass(SavingEntryEntity.self)

        let saveId = NSAttributeDescription()
        saveId.name = "id"; saveId.attributeType = .UUIDAttributeType; saveId.isOptional = false
        let saveDate = NSAttributeDescription()
        saveDate.name = "date"; saveDate.attributeType = .dateAttributeType; saveDate.isOptional = false
        let saveAmount = NSAttributeDescription()
        saveAmount.name = "amount"; saveAmount.attributeType = .doubleAttributeType; saveAmount.defaultValue = 0.0
        let saveNote = NSAttributeDescription()
        saveNote.name = "note"; saveNote.attributeType = .stringAttributeType; saveNote.isOptional = true
        let saveStreakDay = NSAttributeDescription()
        saveStreakDay.name = "streakDay"; saveStreakDay.attributeType = .integer32AttributeType; saveStreakDay.defaultValue = 0

        savingEntryEntity.properties = [saveId, saveDate, saveAmount, saveNote, saveStreakDay]

        //  BadgeEntity
        let badgeEntity = NSEntityDescription()
        badgeEntity.name = "BadgeEntity"
        badgeEntity.managedObjectClassName = NSStringFromClass(BadgeEntity.self)

        let badgeId = NSAttributeDescription()
        badgeId.name = "id"; badgeId.attributeType = .UUIDAttributeType; badgeId.isOptional = false
        let badgeName = NSAttributeDescription()
        badgeName.name = "name"; badgeName.attributeType = .stringAttributeType; badgeName.isOptional = true
        let badgeTypeAttr = NSAttributeDescription()
        badgeTypeAttr.name = "badgeType"; badgeTypeAttr.attributeType = .stringAttributeType; badgeTypeAttr.isOptional = true
        let badgeIsEarned = NSAttributeDescription()
        badgeIsEarned.name = "isEarned"; badgeIsEarned.attributeType = .booleanAttributeType; badgeIsEarned.defaultValue = false
        let badgeEarnedDate = NSAttributeDescription()
        badgeEarnedDate.name = "earnedDate"; badgeEarnedDate.attributeType = .dateAttributeType; badgeEarnedDate.isOptional = true

        badgeEntity.properties = [badgeId, badgeName, badgeTypeAttr, badgeIsEarned, badgeEarnedDate]

        //  DecisionEntryEntity
        let decisionEntryEntity = NSEntityDescription()
        decisionEntryEntity.name = "DecisionEntryEntity"
        decisionEntryEntity.managedObjectClassName = NSStringFromClass(DecisionEntryEntity.self)

        let decisionId = NSAttributeDescription()
        decisionId.name = "id"; decisionId.attributeType = .UUIDAttributeType; decisionId.isOptional = false
        let decisionItem = NSAttributeDescription()
        decisionItem.name = "itemName"; decisionItem.attributeType = .stringAttributeType; decisionItem.isOptional = true
        let decisionPrice = NSAttributeDescription()
        decisionPrice.name = "price"; decisionPrice.attributeType = .doubleAttributeType; decisionPrice.defaultValue = 0.0
        let decisionCat = NSAttributeDescription()
        decisionCat.name = "category"; decisionCat.attributeType = .stringAttributeType; decisionCat.isOptional = true
        let decisionStart = NSAttributeDescription()
        decisionStart.name = "timerStart"; decisionStart.attributeType = .dateAttributeType; decisionStart.isOptional = true
        let decisionIsSave = NSAttributeDescription()
        decisionIsSave.name = "isdSave"; decisionIsSave.attributeType = .booleanAttributeType; decisionIsSave.defaultValue = false

        decisionEntryEntity.properties = [decisionId, decisionItem, decisionPrice, decisionCat, decisionStart, decisionIsSave]

        model.entities = [userGoalEntity, savingEntryEntity, badgeEntity, decisionEntryEntity]

        container = NSPersistentContainer(name: "MiniBudget_New", managedObjectModel: model)

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                print("Core Data load error: \(error), \(error.userInfo)")
            }
        }

        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    func save() {
        let context = container.viewContext
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            print("Core Data save error: \(error.localizedDescription)")
        }
    }
}

// Core Data Entity Classes
@objc(UserGoalEntity)
public class UserGoalEntity: NSManagedObject {
    @NSManaged public var id: UUID?
    @NSManaged public var dailyAmount: Double
    @NSManaged public var targetAmount: Double
    @NSManaged public var currentStreak: Int32
    @NSManaged public var longestStreak: Int32
    @NSManaged public var startDate: Date?

    @discardableResult
    static func createOrUpdate(dailyAmount: Double, targetAmount: Double, in context: NSManagedObjectContext) -> UserGoalEntity {
        let request = NSFetchRequest<UserGoalEntity>(entityName: "UserGoalEntity")
        request.fetchLimit = 1
        let existing = (try? context.fetch(request))?.first

        let goal = existing ?? UserGoalEntity(context: context)
        goal.id = goal.id ?? UUID()
        goal.dailyAmount = dailyAmount
        goal.targetAmount = targetAmount
        goal.startDate = goal.startDate ?? Date()
        return goal
    }

    @discardableResult
    static func updateStreak(in context: NSManagedObjectContext) -> Int32 {
        let request = NSFetchRequest<UserGoalEntity>(entityName: "UserGoalEntity")
        request.fetchLimit = 1
        guard let goal = (try? context.fetch(request))?.first else { return 0 }

        let calendar = Calendar.current
        let savReq   = NSFetchRequest<SavingEntryEntity>(entityName: "SavingEntryEntity")
        let all      = (try? context.fetch(savReq)) ?? []

        // Build set of unique saved dates
        let savedDates = Set(all.compactMap { entry -> Date? in
            guard let d = entry.date else { return nil }
            return calendar.startOfDay(for: d)
        })

        // Walk backwards from today counting consecutive saved days
        var streak: Int32 = 0
        var checkDate = calendar.startOfDay(for: Date())
        while savedDates.contains(checkDate) {
            streak += 1
            guard let prev = calendar.date(byAdding: .day, value: -1, to: checkDate) else { break }
            checkDate = prev
        }

        goal.currentStreak = streak
        if streak > goal.longestStreak { goal.longestStreak = streak }
        return streak
    }
}

@objc(SavingEntryEntity)
public class SavingEntryEntity: NSManagedObject {
    @NSManaged public var id: UUID?
    @NSManaged public var date: Date?
    @NSManaged public var amount: Double
    @NSManaged public var note: String?
    @NSManaged public var streakDay: Int32

    @discardableResult
    static func create(amount: Double, note: String?, streakDay: Int32, in context: NSManagedObjectContext) -> SavingEntryEntity {
        let entry = SavingEntryEntity(context: context)
        entry.id = UUID()
        entry.date = Date()
        entry.amount = amount
        entry.note = note
        entry.streakDay = streakDay
        return entry
    }
}

@objc(BadgeEntity)
public class BadgeEntity: NSManagedObject {
    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var badgeType: String?
    @NSManaged public var isEarned: Bool
    @NSManaged public var earnedDate: Date?

    static func seedAll(in context: NSManagedObjectContext) {
        let request = NSFetchRequest<BadgeEntity>(entityName: "BadgeEntity")
        request.fetchLimit = 1
        guard (try? context.count(for: request)) == 0 else { return }

        let types = ["First Save", "7-Day Streak", "30-Day Streak", "Rs.500 Milestone", "Rs.5000 Goal", "Impulse Master", "Budget Hero"]
        for type in types {
            let badge = BadgeEntity(context: context)
            badge.id = UUID()
            badge.name = type
            badge.badgeType = type
            badge.isEarned = false
        }
    }
}

@objc(DecisionEntryEntity)
public class DecisionEntryEntity: NSManagedObject {
    @NSManaged public var id: UUID?
    @NSManaged public var itemName: String?
    @NSManaged public var price: Double
    @NSManaged public var category: String?
    @NSManaged public var timerStart: Date?
    @NSManaged public var isdSave: Bool
}
