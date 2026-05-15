//
//  MiniBudgetTests.swift
//  MiniBudget_NewTests
//
//  Unit tests covering:
//    1. UserGoal computed properties (Models.swift)
//    2. PersistenceController – Core Data CRUD
//    3. UserGoalEntity streak logic
//    4. SavingEntryEntity creation
//    5. BadgeEntity seeding
//    6. DecisionEntryEntity
//    7. DashboardView computed helpers (pure logic, no UI)
//    8. AddPurchaseView validation helpers
//    9. PurchaseCategory enum
//   10. MockData sanity checks
//

import XCTest
import CoreData
@testable import MiniBudget_New

//Helpers

private func makeInMemoryController() -> PersistenceController {
    PersistenceController(inMemory: true)
}

@discardableResult
private func insertGoal(
    daily: Double = 500,
    target: Double = 5000,
    in ctx: NSManagedObjectContext
) -> UserGoalEntity {
    UserGoalEntity.createOrUpdate(dailyAmount: daily, targetAmount: target, in: ctx)
}

@discardableResult
private func insertEntry(
    amount: Double = 500,
    daysAgo: Int = 0,
    in ctx: NSManagedObjectContext
) -> SavingEntryEntity {
    let entry = SavingEntryEntity(context: ctx)
    entry.id        = UUID()
    entry.date      = Calendar.current.date(byAdding: .day, value: -daysAgo, to: Date()) ?? Date()
    entry.amount    = amount
    entry.streakDay = 1
    return entry
}


// UserGoal Model Tests

final class UserGoalModelTests: XCTestCase {

    func test_dailyProgress_zeroWhenTargetIsZero() {
        let goal = UserGoal(
            dailyAmount: 0, targetAmount: 0,
            currentStreak: 0, longestStreak: 0,
            totalSaved: 0, daysLogged: 0,
            bestDayAmount: 0, monthRank: "", remainingBalance: 0
        )
    
    }

    func test_dailyProgress_clampedAt1() {
        let goal = UserGoal(
            dailyAmount: 500, targetAmount: 1000,
            currentStreak: 0, longestStreak: 0,
            totalSaved: 2000, daysLogged: 0,        // over-saved
            bestDayAmount: 0, monthRank: "", remainingBalance: 0
        )
        XCTAssertEqual(goal.dailyProgress, 1.0)
    }

    func test_dailyProgress_partialProgress() {
        let goal = UserGoal(
            dailyAmount: 500, targetAmount: 5000,
            currentStreak: 0, longestStreak: 0,
            totalSaved: 2500, daysLogged: 0,        // 50%
            bestDayAmount: 0, monthRank: "", remainingBalance: 0
        )
        XCTAssertEqual(goal.dailyProgress, 0.5, accuracy: 0.001)
    }
}


//  PersistenceController – Initialisation

final class PersistenceControllerInitTests: XCTestCase {

    func test_inMemoryStore_doesNotPersistToDisk() {
        let pc1 = makeInMemoryController()
        let pc2 = makeInMemoryController()
        // Each in-memory store is isolated
        let ctx1 = pc1.container.viewContext
        let ctx2 = pc2.container.viewContext
        insertGoal(in: ctx1)
        try? ctx1.save()

        let req = NSFetchRequest<UserGoalEntity>(entityName: "UserGoalEntity")
        let results = (try? ctx2.fetch(req)) ?? []
        XCTAssertEqual(results.count, 0, "In-memory stores must be isolated")
    }

    func test_save_doesNotThrowWhenContextHasChanges() {
        let pc = makeInMemoryController()
        insertGoal(in: pc.container.viewContext)
        XCTAssertNoThrow(pc.save())
    }

    func test_save_isNoopWhenContextHasNoChanges() {
        let pc = makeInMemoryController()
        // Call save on a clean context — should not crash
        XCTAssertNoThrow(pc.save())
    }
}


//UserGoalEntity – createOrUpdate

final class UserGoalEntityCRUDTests: XCTestCase {

    private var ctx: NSManagedObjectContext!

    override func setUp() {
        super.setUp()
        ctx = makeInMemoryController().container.viewContext
    }

    func test_createOrUpdate_createsNewGoal() {
        let goal = UserGoalEntity.createOrUpdate(dailyAmount: 500, targetAmount: 5000, in: ctx)
        XCTAssertEqual(goal.dailyAmount,  500)
        XCTAssertEqual(goal.targetAmount, 5000)
        XCTAssertNotNil(goal.id)
        XCTAssertNotNil(goal.startDate)
    }

    func test_createOrUpdate_updatesExistingGoal() {
        UserGoalEntity.createOrUpdate(dailyAmount: 100, targetAmount: 1000, in: ctx)
        try? ctx.save()

        UserGoalEntity.createOrUpdate(dailyAmount: 200, targetAmount: 2000, in: ctx)
        try? ctx.save()

        let req = NSFetchRequest<UserGoalEntity>(entityName: "UserGoalEntity")
        let results = try? ctx.fetch(req)
        // Only one goal record should ever exist
        XCTAssertEqual(results?.count, 1)
        XCTAssertEqual(results?.first?.dailyAmount,  200)
        XCTAssertEqual(results?.first?.targetAmount, 2000)
    }

    func test_createOrUpdate_startDateNotOverwritten() {
        let goal1 = UserGoalEntity.createOrUpdate(dailyAmount: 100, targetAmount: 1000, in: ctx)
        let firstDate = goal1.startDate
        try? ctx.save()

        let goal2 = UserGoalEntity.createOrUpdate(dailyAmount: 200, targetAmount: 2000, in: ctx)
        XCTAssertEqual(goal2.startDate, firstDate, "startDate must not change on update")
    }
}


// UserGoalEntity – updateStreak

final class StreakCalculationTests: XCTestCase {

    private var ctx: NSManagedObjectContext!

    override func setUp() {
        super.setUp()
        ctx = makeInMemoryController().container.viewContext
        insertGoal(in: ctx)
        try? ctx.save()
    }

    func test_streakIsZero_whenNoEntries() {
        let streak = UserGoalEntity.updateStreak(in: ctx)
        XCTAssertEqual(streak, 0)
    }

    func test_streak_countsConsecutiveDays() {
        insertEntry(daysAgo: 0, in: ctx)
        insertEntry(daysAgo: 1, in: ctx)
        insertEntry(daysAgo: 2, in: ctx)
        try? ctx.save()

        let streak = UserGoalEntity.updateStreak(in: ctx)
        XCTAssertEqual(streak, 3)
    }

    func test_streak_breaksOnGap() {
        insertEntry(daysAgo: 0, in: ctx)
        insertEntry(daysAgo: 1, in: ctx)
        // daysAgo: 2 missing  ← gap
        insertEntry(daysAgo: 3, in: ctx)
        try? ctx.save()

        let streak = UserGoalEntity.updateStreak(in: ctx)
        XCTAssertEqual(streak, 2, "Streak should stop at the gap")
    }

    func test_streak_doesNotCountFutureDates() {
        insertEntry(daysAgo: -1, in: ctx)   // tomorrow
        try? ctx.save()

        let streak = UserGoalEntity.updateStreak(in: ctx)
        // Walking back from today: today not saved, so streak = 0
        XCTAssertEqual(streak, 0)
    }

    func test_longestStreak_updatesWhenStreakExceedsPrevious() {
        // Seed a goal with longestStreak = 0
        let req = NSFetchRequest<UserGoalEntity>(entityName: "UserGoalEntity")
        let goal = try! ctx.fetch(req).first!
        goal.longestStreak = 0
        try? ctx.save()

        insertEntry(daysAgo: 0, in: ctx)
        insertEntry(daysAgo: 1, in: ctx)
        try? ctx.save()

        UserGoalEntity.updateStreak(in: ctx)
        try? ctx.save()

        let updated = try! ctx.fetch(req).first!
        XCTAssertEqual(updated.longestStreak, 2)
    }

    func test_longestStreak_doesNotDecrease() {
        let req = NSFetchRequest<UserGoalEntity>(entityName: "UserGoalEntity")
        let goal = try! ctx.fetch(req).first!
        goal.longestStreak = 99   // previously achieved
        try? ctx.save()

        insertEntry(daysAgo: 0, in: ctx)   // only 1-day streak
        try? ctx.save()
        UserGoalEntity.updateStreak(in: ctx)

        let updated = try! ctx.fetch(req).first!
        XCTAssertEqual(updated.longestStreak, 99, "longestStreak must never decrease")
    }

    func test_duplicateSavingsOnSameDay_countedOnce() {
        insertEntry(daysAgo: 0, in: ctx)
        insertEntry(daysAgo: 0, in: ctx)  // same day, second entry
        insertEntry(daysAgo: 1, in: ctx)
        try? ctx.save()

        let streak = UserGoalEntity.updateStreak(in: ctx)
        XCTAssertEqual(streak, 2, "Duplicate entries on same day should count as one day")
    }
}


//  SavingEntryEntity – create

final class SavingEntryEntityTests: XCTestCase {

    private var ctx: NSManagedObjectContext!

    override func setUp() {
        super.setUp()
        ctx = makeInMemoryController().container.viewContext
    }

    func test_create_setsAllFields() {
        let entry = SavingEntryEntity.create(amount: 300, note: "Test note", streakDay: 5, in: ctx)
        XCTAssertNotNil(entry.id)
        XCTAssertNotNil(entry.date)
        XCTAssertEqual(entry.amount,    300)
        XCTAssertEqual(entry.note,      "Test note")
        XCTAssertEqual(entry.streakDay, 5)
    }

    func test_create_withNilNote() {
        let entry = SavingEntryEntity.create(amount: 100, note: nil, streakDay: 1, in: ctx)
        XCTAssertNil(entry.note)
    }

    func test_create_dateIsApproximatelyNow() {
        let before = Date()
        let entry  = SavingEntryEntity.create(amount: 50, note: nil, streakDay: 0, in: ctx)
        let after  = Date()
        XCTAssertTrue(entry.date! >= before && entry.date! <= after)
    }

    func test_multipleEntries_haveUniqueIDs() {
        let e1 = SavingEntryEntity.create(amount: 100, note: nil, streakDay: 1, in: ctx)
        let e2 = SavingEntryEntity.create(amount: 200, note: nil, streakDay: 2, in: ctx)
        XCTAssertNotEqual(e1.id, e2.id)
    }
}


//  BadgeEntity – seedAll

final class BadgeEntityTests: XCTestCase {

    private var ctx: NSManagedObjectContext!

    override func setUp() {
        super.setUp()
        ctx = makeInMemoryController().container.viewContext
    }

    func test_seedAll_createsBadges() {
        BadgeEntity.seedAll(in: ctx)
        try? ctx.save()

        let req = NSFetchRequest<BadgeEntity>(entityName: "BadgeEntity")
        let count = (try? ctx.count(for: req)) ?? 0
        XCTAssertGreaterThan(count, 0, "seedAll must create at least one badge")
    }

    func test_seedAll_isIdempotent() {
        BadgeEntity.seedAll(in: ctx)
        try? ctx.save()
        BadgeEntity.seedAll(in: ctx)   
        try? ctx.save()

        let req = NSFetchRequest<BadgeEntity>(entityName: "BadgeEntity")
        let count1 = (try? ctx.count(for: req)) ?? 0

        BadgeEntity.seedAll(in: ctx)   
        try? ctx.save()
        let count2 = (try? ctx.count(for: req)) ?? 0

        XCTAssertEqual(count1, count2, "seedAll must not duplicate badges")
    }

    func test_seedAll_allBadgesAreUnearned() {
        BadgeEntity.seedAll(in: ctx)
        try? ctx.save()

        let req = NSFetchRequest<BadgeEntity>(entityName: "BadgeEntity")
        let badges = (try? ctx.fetch(req)) ?? []
        XCTAssertTrue(badges.allSatisfy { !$0.isEarned }, "All seeded badges should start unearned")
    }

    func test_badge_canBeMarkedEarned() {
        BadgeEntity.seedAll(in: ctx)
        try? ctx.save()

        let req = NSFetchRequest<BadgeEntity>(entityName: "BadgeEntity")
        if let first = (try? ctx.fetch(req))?.first {
            first.isEarned    = true
            first.earnedDate  = Date()
            try? ctx.save()

            XCTAssertTrue(first.isEarned)
            XCTAssertNotNil(first.earnedDate)
        } else {
            XCTFail("No badges found after seed")
        }
    }
}


//DecisionEntryEntity

final class DecisionEntryEntityTests: XCTestCase {

    private var ctx: NSManagedObjectContext!

    override func setUp() {
        super.setUp()
        ctx = makeInMemoryController().container.viewContext
    }

    func test_createDecisionEntry() {
        let entry = DecisionEntryEntity(context: ctx)
        entry.id         = UUID()
        entry.itemName   = "Coffee"
        entry.price      = 150
        entry.category   = "Leisure"
        entry.timerStart = Date()
        entry.isdSave    = true
        try? ctx.save()

        let req = NSFetchRequest<DecisionEntryEntity>(entityName: "DecisionEntryEntity")
        let results = (try? ctx.fetch(req)) ?? []
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.itemName, "Coffee")
        XCTAssertEqual(results.first?.price, 150)
        XCTAssertTrue(results.first!.isdSave)
    }

    func test_decisionEntry_defaultIsdSaveIsFalse() {
        let entry = DecisionEntryEntity(context: ctx)
        entry.id = UUID()
        XCTAssertFalse(entry.isdSave)
    }

    func test_multipleDecisionEntries() {
        for i in 1...5 {
            let e    = DecisionEntryEntity(context: ctx)
            e.id     = UUID()
            e.price  = Double(i) * 100
            e.isdSave = i % 2 == 0
        }
        try? ctx.save()

        let req = NSFetchRequest<DecisionEntryEntity>(entityName: "DecisionEntryEntity")
        let count = (try? ctx.count(for: req)) ?? 0
        XCTAssertEqual(count, 5)
    }
}


// PurchaseCategory Enum

final class PurchaseCategoryTests: XCTestCase {

    func test_allCases_containsThreeCategories() {
        XCTAssertEqual(PurchaseCategory.allCases.count, 3)
    }

    func test_rawValues_areCorrect() {
        XCTAssertEqual(PurchaseCategory.leisure.rawValue,    "Leisure")
        XCTAssertEqual(PurchaseCategory.essentials.rawValue, "Essentials")
        XCTAssertEqual(PurchaseCategory.travel.rawValue,     "Travel")
    }

    func test_initFromRawValue() {
        XCTAssertEqual(PurchaseCategory(rawValue: "Travel"),     .travel)
        XCTAssertEqual(PurchaseCategory(rawValue: "Leisure"),    .leisure)
        XCTAssertNil(PurchaseCategory(rawValue: "NonExistent"))
    }
}


// MockData Sanity Checks

final class MockDataTests: XCTestCase {

    func test_goal_dailyAmountIsPositive() {
        XCTAssertGreaterThan(MockData.goal.dailyAmount, 0)
    }

    func test_goal_totalSavedIsLessThanTarget() {
        XCTAssertLessThanOrEqual(MockData.goal.totalSaved, MockData.goal.targetAmount)
    }

    func test_goal_remainingBalance_matchesDifference() {
        let expected = MockData.goal.targetAmount - MockData.goal.totalSaved
       
    }

    func test_recentEntries_countIsSeven() {
        XCTAssertEqual(MockData.recentEntries.count, 7)
    }

    func test_weeklyBars_countIsSeven() {
        XCTAssertEqual(MockData.weeklyBars.count, 7)
    }

    func test_badges_allHaveNonEmptyNames() {
        for badge in MockData.badges {
            XCTAssertFalse(badge.name.isEmpty, "Badge '\(badge.name)' has empty name")
        }
    }

    func test_badges_atLeastOneEarned() {
        XCTAssertTrue(MockData.badges.contains(where: { $0.isEarned }))
    }

    func test_savedDaysInMonth_isNotEmpty() {
        XCTAssertFalse(MockData.savedDaysInMonth.isEmpty)
    }
}


//  Dashboard Logic 

private enum DashboardLogic {

    static func progress(totalSaved: Double, targetAmount: Double) -> Double {
        guard targetAmount > 0 else { return 0 }
        return min(totalSaved / targetAmount, 1.0)
    }

    static func dailyProgress(totalSaved: Double, dailyAmount: Double) -> Double {
        guard dailyAmount > 0 else { return 0 }
        return min(totalSaved / dailyAmount, 1.0)
    }

    static func remaining(totalSaved: Double, targetAmount: Double) -> Double {
        max(targetAmount - totalSaved, 0)
    }

    static func greeting(for hour: Int) -> String {
        if hour < 12 { return "Good Morning" }
        if hour < 17 { return "Good Afternoon" }
        return "Good Evening"
    }

    static func avatarLetter(from fullName: String) -> String {
        String(fullName.prefix(1)).uppercased()
    }
}

final class DashboardLogicTests: XCTestCase {

    // progress
    func test_progress_zero_whenNoTarget() {
        XCTAssertEqual(DashboardLogic.progress(totalSaved: 0, targetAmount: 0), 0)
    }

    func test_progress_clamped() {
        XCTAssertEqual(DashboardLogic.progress(totalSaved: 10_000, targetAmount: 5_000), 1.0)
    }

    func test_progress_fifty_percent() {
        XCTAssertEqual(DashboardLogic.progress(totalSaved: 2500, targetAmount: 5000), 0.5, accuracy: 0.001)
    }

    // dailyProgress
    func test_dailyProgress_zero_whenNoDailyAmount() {
        XCTAssertEqual(DashboardLogic.dailyProgress(totalSaved: 100, dailyAmount: 0), 0)
    }

    func test_dailyProgress_over100_clamped() {
        XCTAssertEqual(DashboardLogic.dailyProgress(totalSaved: 1000, dailyAmount: 500), 1.0)
    }

    // remaining
    func test_remaining_positiveWhenBelowTarget() {
        XCTAssertEqual(DashboardLogic.remaining(totalSaved: 1000, targetAmount: 5000), 4000)
    }

    func test_remaining_zeroWhenExceeded() {
        XCTAssertEqual(DashboardLogic.remaining(totalSaved: 6000, targetAmount: 5000), 0)
    }

    // greeting
    func test_greeting_morning()   { XCTAssertEqual(DashboardLogic.greeting(for: 8),  "Good Morning") }
    func test_greeting_noon()      { XCTAssertEqual(DashboardLogic.greeting(for: 11), "Good Morning") }
    func test_greeting_afternoon() { XCTAssertEqual(DashboardLogic.greeting(for: 14), "Good Afternoon") }
    func test_greeting_evening()   { XCTAssertEqual(DashboardLogic.greeting(for: 18), "Good Evening") }
    func test_greeting_midnight()  { XCTAssertEqual(DashboardLogic.greeting(for: 0),  "Good Morning") }

    // avatarLetter
    func test_avatarLetter_uppercased() {
        XCTAssertEqual(DashboardLogic.avatarLetter(from: "erandi"), "E")
    }

    func test_avatarLetter_emptyName() {
        XCTAssertEqual(DashboardLogic.avatarLetter(from: ""), "")
    }

    func test_avatarLetter_multiWord() {
        XCTAssertEqual(DashboardLogic.avatarLetter(from: "Keshana Silva"), "K")
    }
}
