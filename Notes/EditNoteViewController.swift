//
//  EditNoteViewController.swift
//  Notes
//
//  Created by Anna Shuryaeva on 12.02.2023.
//

import UIKit

class EditNoteViewController: UIViewController {
    
    // MARK: - Properties
    var note: NoteItem?
    weak var delegate: NotesListDelegate?
    
    private let dataManager = CoreDataManager.shared
    private lazy var titleTextField = UITextField()
    private lazy var textView = UITextView()

    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setConstraintsForTextField()
        setConstraintsForTextView()
        configureTitle()
        configureTextView()
        configureBackButton()
//        configureDoneButton()
        configureDeleteButton()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        textView.becomeFirstResponder()
    }
    
    // MARK: - Methods
    
    private func configureTitle() {
        titleTextField.text = note?.title
        titleTextField.placeholder = "Note title"
        titleTextField.layer.cornerRadius = 10
        titleTextField.layer.borderWidth = 1.0
        titleTextField.setLeftPaddingPoints(10)
        titleTextField.autocorrectionType = .no
        titleTextField.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    private func configureTextView() {
        textView.text = note?.details
        textView.layer.cornerRadius = 10
        textView.layer.borderWidth = 1.0
        textView.font = UIFont(name: "Arial", size: 17.0)
        textView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.autocorrectionType = .no
        textView.isScrollEnabled = true
        textView.isSelectable = true
        textView.isEditable = true
    }
    
    private func configureBackButton() {
        let backButton = UIBarButtonItem(image: UIImage(systemName: "arrow.backward"), style: .plain, target: self, action: #selector(updateOrDeleteNote))
        backButton.tintColor = UIColor(named: "textColor")
        navigationItem.leftBarButtonItem = backButton
    }
    
//    private func configureDoneButton() {
//        let saveButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(tapSave))
//        saveButton.tintColor = UIColor(named: "textColor")
//        navigationItem.rightBarButtonItem = saveButton
//    }
    
    private func configureDeleteButton() {
        let deleteButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(showAlertWhenDelete))
        deleteButton.tintColor = UIColor(named: "textColor")
        navigationItem.rightBarButtonItems = [deleteButton]
    }
    
    //MARK: - AlertController
    @objc private func showAlertWhenDelete() {
        let alert = UIAlertController(title: "Delete this note?", message: nil, preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Yes", style: .default) { _ in
            self.deleteNote()
            self.navigationController?.popViewController(animated: true)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        alert.addAction(cancelAction)
        alert.addAction(yesAction)
        present(alert, animated: true)
    }
    
        
//    @objc private func tapSave() {
//        print("Tap")
//        titleTextField.endEditing(true)
//        textView.isEditable = false
//        textView.endEditing(true)
// 
//        dismiss(animated: true)
//    }
    
    private func updateTextForNote() {
        note?.title = titleTextField.text
        note?.details = textView.text
        note?.date = Date()
        dataManager.saveContext()
        delegate?.updateNotes()
    }
    
    @objc private func updateOrDeleteNote() {
        note?.title = titleTextField.text
        note?.details = textView.text
        
        if note?.title == "" && note?.details == "" {
            deleteNote()
        } else {
            note?.title = titleTextField.text
            note?.details = textView.text
            updateTextForNote()
        }
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func deleteNote() {
        if note != nil, note?.identifier != nil {
            delegate?.deleteNote(identifier: (note?.identifier)! )
            dataManager.deleteNote(note: note!)
        }
    }
}


extension EditNoteViewController: UITextViewDelegate, UITextFieldDelegate {
    
    
}

extension EditNoteViewController {
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
}
extension EditNoteViewController {
    
    private func setConstraintsForTextView() {
        view.addSubview(textView)
        textView.delegate = self
        
        textView.snp.makeConstraints {
            $0.left.right.equalTo(view.safeAreaLayoutGuide).inset(10)
            $0.top.equalTo(titleTextField.snp.bottom).offset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(300)
        }
    }
    
//    private func setupSaveButton() {
//        view.addSubview(saveButton)
//        
//        saveButton.snp.makeConstraints {
//            $0.top.equalTo(view).inset(55)
//            $0.right.equalToSuperview().inset(16)
//        }
//    }
    
    private func setConstraintsForTextField() {
        view.addSubview(titleTextField)
        titleTextField.delegate = self
        
        titleTextField.snp.makeConstraints {
            $0.top.left.right.equalTo(view.safeAreaLayoutGuide).inset(10)
            $0.height.equalTo(50)
        }
    }
}

extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
}

extension EditNoteViewController {
    //MARK: - Gestures
    private func setUpGesture() {
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(updateOrDeleteNote))
        swipeRight.direction = .right
        view.addGestureRecognizer(swipeRight)
    }
}
