//
//  AirAlertStatesProvider.swift
//  air-raid-map
//
//  Created by Nazar Rudnyk on 28.06.2022.
//

import CoreData
import OSLog

class AirAlertStatesProvider {

    static let shared = AirAlertStatesProvider()

    // A quakes provider for use with canvas previews.
    static let preview: AirAlertStatesProvider = {
        let provider = AirAlertStatesProvider(inMemory: true)
        AirAlertState.makePreviews(count: 10)
        return provider
    }()

    private let inMemory: Bool
    private var notificationToken: NSObjectProtocol?

    private init(inMemory: Bool = false) {
        self.inMemory = inMemory

        // Observe Core Data remote change notifications on the queue where the changes were made.
        notificationToken = NotificationCenter.default.addObserver(forName: .NSPersistentStoreRemoteChange, object: nil, queue: nil) { note in
            Logger.persistence.debug("Received a persistent store remote change notification.")
            Task {
                await self.fetchPersistentHistory()
            }
        }
    }

    deinit {
        if let observer = notificationToken {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    /// A peristent history token used for fetching transactions from the store.
    private var lastToken: NSPersistentHistoryToken?

    /// A persistent container to set up the Core Data stack.
    lazy var container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "AirRaidAlerts")
        guard let description = container.persistentStoreDescriptions.first else {
            fatalError("Failed to retrieve a persistent store description.")
        }

        if inMemory { description.url = URL(fileURLWithPath: "/dev/null") }
        description.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)

        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }

        // This sample refreshes UI by consuming store changes via persistent history tracking.
        container.viewContext.automaticallyMergesChangesFromParent = false
        container.viewContext.name = "viewContext"
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.undoManager = nil
        container.viewContext.shouldDeleteInaccessibleFaults = true

        return container
    }()

    func save() {
        let context = container.viewContext

        if context.hasChanges {
            do {
                try context.save()
                print("Success")
            } catch {
                print("Error saving: \(error)")
            }
        }
    }

    func newBackgroundTaskContext() -> NSManagedObjectContext {
        let taskContext = container.newBackgroundContext()
        taskContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        taskContext.undoManager = nil

        return taskContext
    }

    func fetchPersistentHistory() async {
        do {
            try await fetchPersistentHistoryTransactionsAndChanges()
        } catch {
            Logger.persistence.debug("\(error.localizedDescription)")
        }
    }

    private func fetchPersistentHistoryTransactionsAndChanges() async throws {
        let taskContext = newBackgroundTaskContext()
        taskContext.name = "persistentHistoryContext"
        Logger.persistence.debug("Start fetching persistent history changes from the store...")

        try await taskContext.performBlock {
            let changeRequest = NSPersistentHistoryChangeRequest.fetchHistory(after: self.lastToken)
    
            let historyResult = try taskContext.execute(changeRequest) as? NSPersistentHistoryResult
            if let history = historyResult?.result as? [NSPersistentHistoryTransaction],
               !history.isEmpty {
                self.mergePersistentHistoryChanges(from: history)
                return
            }

            Logger.persistence.debug("No persistent history transactions found.")
            throw AirAlertStateError.persistentHistoryChangeError
        }

        Logger.persistence.debug("Finished merging history changes.")
    }

    private func mergePersistentHistoryChanges(from history: [NSPersistentHistoryTransaction]) {
        Logger.persistence.debug("Received \(history.count) persistent history transactions.")

        // Update view context with objectIDs from history change request.
        let viewContext = container.viewContext
        viewContext.perform {
            for transaction in history {
                viewContext.mergeChanges(fromContextDidSave: transaction.objectIDNotification())
                self.lastToken = transaction.token
            }
        }
    }
}
