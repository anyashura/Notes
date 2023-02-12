//
//  NotesListViewController.swift
//  Notes
//
//  Created by Anna Shuryaeva on 12.02.2023.
//

import UIKit
import SnapKit
import CoreData

class NotesListViewController: UIViewController {

    // MARK: - Properties
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let cellID = "cellID"
    var notes = [NoteItem]()
//    private let editingVC = EditViewController()
    private let searchController = UISearchController()
    
    
    private var collectionView: UICollectionView?
    
    // MARK: - Actions
    
    private func configureCollection() {
        let layout = UICollectionViewFlowLayout()
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.backgroundColor = .white
        collectionView?.showsVerticalScrollIndicator = false

        collectionView?.register(NotesListCollectionViewCell.self, forCellWithReuseIdentifier: cellID)
        view.addSubview(collectionView ?? UICollectionView())
        layout.itemSize = CGSize(width: (view.frame.size.width - 20), height: 65)

    }
    
//    private func configureSearchBar() {
//        navigationItem.searchController = searchController
//        searchController.obscuresBackgroundDuringPresentation = true
//        searchController.searchBar.delegate = self
//        searchController.delegate = self
//    }
    
    private func firstLaunchCheck() {
        let defaults = UserDefaults.standard
        if defaults.bool(forKey: "firstLaunch") != true {
            defaults.set(true, forKey: "firstLaunch")
            createNote(name: "First note", text: "Text")
        }
    }
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firstLaunchCheck()
        configureCollection()

        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Notes"
//        configureSearchBar()
        loadNotes()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAdd))
    }
    
    override func viewWillAppear(_ animated: Bool) {
           loadNotes()
       }
    
    // MARK: - Layout

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView?.frame = view.bounds
    }
    
    @objc func didTapAdd() {
//        self.navigationController?.pushViewController(editingVC, animated: true)
    }

    // MARK: - CoreData
//    func getAllNotes() {
//        do {
//            notes = try context.fetch(NoteItem.fetchRequest())
//            DispatchQueue.main.async {
//                self.tableView.reloadData()
//            }
//        }
//        catch {
//
//        }
//
//    }
    
    // Load the notes from Core Data
    func loadNotes() {
        let fetchRequest:NSFetchRequest<NoteItem> = NoteItem.fetchRequest()
        
        do {
            notes = try context.fetch(fetchRequest)
            DispatchQueue.main.async {
                self.collectionView?.reloadData()
            }
        } catch {
            print("cannot fetch from database")
        }
    }

    func createNote(name: String, text: String) {
        let newNote = NoteItem(context: context)
        newNote.title = name
        newNote.date = Date()
        newNote.details = text
        do {
            try context.save()
            loadNotes()
        }
        catch {
            print("cannot fetch from database")
        }
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

    func updateNote(note: NoteItem, newName: String) {
        note.title = newName
        do {
            try context.save()
        }
        catch {
            print("cannot fetch from database")
        }
    }
}

// MARK: - Extensions

extension NotesListViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as? NotesListCollectionViewCell else {
            return UICollectionViewCell()
        }
        let note = notes[indexPath.row]
        cell.setup(note: note)
        return cell

    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(notes.count)
        return notes.count
    }
}

extension NotesListViewController: UICollectionViewDelegate {}



