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
        configureDeleteButton()
        registerKeyboardNotifications()
        setUpGesture()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        titleTextField.becomeFirstResponder()
    }
    
    // MARK: - Methods
    
    private func configureTitle() {
        titleTextField.text = note?.title
        titleTextField.placeholder = "Note title"
        titleTextField.backgroundColor = .gray.withAlphaComponent(0.1)
        titleTextField.layer.cornerRadius = 10
        titleTextField.layer.borderWidth = 1.0
        titleTextField.setLeftPaddingPoints(15)
        titleTextField.autocorrectionType = .no
        titleTextField.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    private func configureTextView() {
        textView.text = note?.details
        textView.layer.cornerRadius = 10
        textView.layer.borderWidth = 1.0
        textView.backgroundColor = .gray.withAlphaComponent(0.1)
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
    
    private func updateTextForNote() {
        if titleTextField.text == "" {
            note?.title = "No name"
        } else {
            note?.title = titleTextField.text
        }
        if textView.text == "" {
            note?.details = "No description"
        } else {
            note?.details = textView.text
        }
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
    
    //MARK: - Notifications
    private func registerKeyboardNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(upadateTextView),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(upadateTextView),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    @objc private func upadateTextView(_ notification: Notification) {
        let userInfo = notification.userInfo
        let getKeyboardSize = (userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue

        let keyboardFrame = self.view.convert(getKeyboardSize, to: view.window)

        if notification.name == UIResponder.keyboardWillHideNotification {
            textView.contentInset = UIEdgeInsets.zero
        } else {
            textView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardFrame.height, right: 0)
            textView.scrollIndicatorInsets = textView.contentInset
        }
        textView.scrollRangeToVisible(textView.selectedRange)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
}


extension EditNoteViewController: UITextViewDelegate, UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == textField {
            textField.resignFirstResponder()
            textView.becomeFirstResponder()
        }
        return true
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
    // MARK: - Padding for TextView
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
