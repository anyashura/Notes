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
    var filteredNotes = [NoteItem]()
    let dataManager = CoreDataManager.shared
    private let editingVC = EditNoteViewController()
    let searchController = UISearchController()
    private let searchBar: UISearchBar = {
        let search = UISearchBar()
        search.placeholder = "Search"
        search.isTranslucent = true
        return search
    }()
    
    private var collectionView: UICollectionView?
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firstLaunchCheck()
        configureCollection()
        getAllNotes()
//        configureSearchBar()
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Notes"
        DispatchQueue.main.async {
            self.collectionView?.reloadData()
        }
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "square.and.pencil"), style: .plain, target: self, action: #selector(didTapAdd))
    }
    
    // MARK: - Layout

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView?.frame = view.bounds
    }
    
    // MARK: - Methods
    
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
//        
//        searchController.searchResultsUpdater = self
//        navigationItem.hidesSearchBarWhenScrolling = false
//        searchController.showsSearchResultsController = true
//        searchController.obscuresBackgroundDuringPresentation = false
//        definesPresentationContext = true
//        searchController.searchBar.delegate = self
//    }
    
    private func firstLaunchCheck() {
        let defaults = UserDefaults.standard
        if defaults.bool(forKey: "firstLaunch") != true {
            defaults.set(true, forKey: "firstLaunch")
            let note = dataManager.createNote(name: "First", text: "Hello")
            notes.insert(note, at: 0)
        }
    }
    
    @objc func didTapAdd() {
        goToEditNoteVC(note: createNote())
    }
    
    private func goToEditNoteVC(note: NoteItem) {
        let editingVC = EditNoteViewController()
        editingVC.note = note
        editingVC.delegate = self
        navigationController?.pushViewController(editingVC, animated: true)
    }
    
    private func createNote() -> NoteItem {
        let note = dataManager.createNote()
        notes.insert(note, at: 0)
        collectionView?.insertItems(at: [IndexPath.init(row: 0, section: 0)])
        return note
    }

    private func getAllNotes() {
        dataManager.loadNotes { result in
            switch result {
            case .success(let notes):
                self.notes = notes
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        DispatchQueue.main.async {
            self.collectionView?.reloadData()
        }
    }
    
    private func indexForNote(id: UUID, notes: [NoteItem]) -> IndexPath {
        let row = Int(notes.firstIndex(where: { $0.identifier == id }) ?? 0)
        return IndexPath(row: row, section: 0)
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

extension NotesListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        goToEditNoteVC(note: notes[indexPath.row])
        collectionView.deselectItem(at: indexPath, animated: true)
        collectionView.reloadItems(at: [indexPath])
    }
}

extension NotesListViewController: NotesListDelegate {
    
    func updateNotes() {
        notes = notes.sorted { $0.date ?? Date() > $1.date ?? Date() }
        collectionView?.reloadData()
    }
    
    func deleteNote(identifier: UUID) {
        let indexPath = indexForNote(id: identifier, notes: notes)
        notes.remove(at: indexPath.row)
        collectionView?.deleteItems(at: [indexPath])
    }
}

extension NotesListViewController: UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        filterCounterForSearchText(text)
    }
    
    func filterCounterForSearchText(_ searchText: String) {
        filteredNotes = notes.filter { $0.title!.lowercased().contains(searchText.lowercased()) }
        collectionView?.reloadData()
    }
}


