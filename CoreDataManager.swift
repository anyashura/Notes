//
//  CoreDataManager.swift
//  Notes
//
//  Created by Anna Shuryaeva on 13.02.2023.
//

import Foundation
import CoreData
import UIKit

class CoreDataManager {
    
    static let shared = CoreDataManager()

    var persistentContainer: NSPersistentContainer = {

        let container = NSPersistentContainer(name: "Notes")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    lazy var context: NSManagedObjectContext = persistentContainer.viewContext

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    // MARK: - CRUD
    // Load notes from Core Data
    func loadNotes(completion: (Result<[NoteItem], Error>) -> Void) {
        
        let fetchRequest:NSFetchRequest<NoteItem> = NoteItem.fetchRequest()
        do {
            let sortDescriptor = NSSortDescriptor(keyPath: \NoteItem.date, ascending: false)
            fetchRequest.sortDescriptors = [sortDescriptor]
            
            let notes = try context.fetch(fetchRequest)
            completion(.success(notes))
        } catch let error {
            completion(.failure(error))
        }
    }

    func createNote(name: String = "", text: String = "") -> NoteItem {
        let newNote = NoteItem(context: context)
        newNote.identifier = UUID()
        newNote.title = name
        newNote.date = Date()
        newNote.details = text
        do {
            try context.save()
        }
        catch {
            print("cannot create note")
        }
        return newNote
    }
    
    func deleteNote(note: NoteItem) {
        context.delete(note)
        do {
            try context.save()
        }
        catch {
            print("cannot fetch from database")
        }
    }

    func updateNote(note: NoteItem, newName: String, text: String) {
        note.title = newName
        note.details = text
        note.date = Date()
        note.identifier = UUID()
        do {
            try context.save()
        }
        catch {
            print("cannot fetch from database")
        }
    }
}
