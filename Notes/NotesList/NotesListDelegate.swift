//
//  NotesListDelegate.swift
//  Notes
//
//  Created by Anna Shuryaeva on 14.02.2023.
//

import Foundation

protocol NotesListDelegate: AnyObject {
    func updateNotes()
    func deleteNote(identifier: UUID)
}
