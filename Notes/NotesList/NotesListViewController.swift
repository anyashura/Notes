//
//  NotesListViewController.swift
//  Notes
//
//  Created by Anna Shuryaeva on 12.02.2023.
//

import UIKit
import SnapKit
import CoreData

final class NotesListViewController: UIViewController {
    // MARK: - Enum
    private enum Constants {
        static let cellID = "cellID"
        static let title = "Notes"
        static let newNote = "square.and.pencil"
        static let firstLaunchKey = "firstLaunch"
    }

    // MARK: - Properties
    
    let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
    
    private let dataManager = CoreDataManager.shared
    private let editingVC = EditNoteViewController()
    private let searchController = UISearchController(searchResultsController: nil)
    private var notes = [NoteItem]()
    private var searchedNotes = [NoteItem]()
    private var collectionView: UICollectionView?
    private var filterIsActive: Bool {
        searchController.isActive
    }
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        getAllNotes()
        firstLaunchCheck()
        configureCollection()
        configureSearchBar()
    }
    
    // MARK: - Layout

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        addConstraintsForCollectionView()
    }
    
    // MARK: - Methods
    
    // Configure UI
    private func configureView() {
        view.backgroundColor = .white
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: Constants.newNote), style: .plain, target: self, action: #selector(didTapAdd))
        title = Constants.title
    }
    
    private func configureCollection() {
        let layout = UICollectionViewFlowLayout()
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.backgroundColor = .white
        collectionView?.showsVerticalScrollIndicator = false

        collectionView?.register(NotesListCollectionViewCell.self, forCellWithReuseIdentifier: Constants.cellID)
        view.addSubview(collectionView ?? UICollectionView())
        layout.itemSize = CGSize(width: (view.frame.size.width - 20), height: 65)
    }
    
    private func configureSearchBar() {
        navigationItem.searchController = searchController
        searchController.searchResultsUpdater = self
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.showsSearchResultsController = true
        searchController.obscuresBackgroundDuringPresentation = false
        definesPresentationContext = true
    }
    
    // Check if there aren't notes and add it
    private func firstLaunchCheck() {
        let defaults = UserDefaults.standard
        if defaults.bool(forKey: Constants.firstLaunchKey) != true {
            defaults.set(true, forKey: Constants.firstLaunchKey)
            let note = dataManager.createNote(name: "First", text: "Hello")
            notes.insert(note, at: 0)
        }
    }
    
    // Add new note
    @objc func didTapAdd() {
        goToEditNoteVC(note: createNote())
    }
    // Edit note
    private func goToEditNoteVC(note: NoteItem) {
        let editingVC = EditNoteViewController()
        editingVC.note = note
        editingVC.delegate = self
        navigationController?.pushViewController(editingVC, animated: true)
        self.collectionView?.reloadData()
    }
    
    // Create new note
    private func createNote() -> NoteItem {
        let note = dataManager.createNote()
        notes.insert(note, at: 0)
        collectionView?.insertItems(at: [IndexPath.init(row: 0, section: 0)])
        return note
    }
    
    // Load all note (Core Data)
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
    
    // Make id for note
    private func indexForNote(id: UUID, notes: [NoteItem]) -> IndexPath {
        let row = Int(notes.firstIndex(where: { $0.identifier == id }) ?? 0)
        return IndexPath(row: row, section: 0)
    }
}

    // MARK: - Extensions
extension NotesListViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.cellID, for: indexPath) as? NotesListCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        if filterIsActive {
            print(searchedNotes.count)
            print(indexPath.row)
            cell.setup(note: searchedNotes[indexPath.row])
            return cell
        }
        
        let note = notes[indexPath.row]
        cell.setup(note: note)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if filterIsActive {
            return searchedNotes.count
        }
        return notes.count
    }
}

extension NotesListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if filterIsActive {
            goToEditNoteVC(note: searchedNotes[indexPath.row])
            self.searchController.isActive = false
        } else {
            goToEditNoteVC(note: notes[indexPath.row])

        }
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

extension NotesListViewController {
    func addConstraintsForCollectionView() {
        collectionView?.snp.makeConstraints {
            $0.top.equalTo(view)
            $0.left.right.bottom.equalToSuperview().inset(10)
        }
    }
}

extension NotesListViewController: UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        filterSearchText(text)
    }
    
    func filterSearchText(_ searchText: String) {
        searchedNotes = notes.filter { ($0.details?.lowercased().contains(searchText.lowercased()))! || ($0.title?.lowercased().contains(searchText.lowercased()))! }
        collectionView?.reloadData()
    }
}
