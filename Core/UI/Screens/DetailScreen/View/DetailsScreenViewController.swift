////
////  NoteDetails.swift
////  TestTask
////
////  Created by G G on 28.12.2022.
////
//

import UIKit
import Photos
import PhotosUI

//MARK: Protocol

protocol DetailsScreenProtocol: AnyObject {
    func success(attString: NSAttributedString)
    func failure()
}

//MARK: Properites

class DetailsScreenViewController: UIViewController,
                                   UITextViewDelegate,
                                   ViewControllerProtocol {
    
    
    var presenter: DetailsScreenPresenterProtocol!
    var attString: NSAttributedString!
    var noteIndex: Int?
    var textView = UITextView()
    var isStyleEditing = false
    var styleKeyboardService: StyleKeyboardService!
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        return contentView
    }()
    
    let accessoryView: UIView = {
        let view = UIView()
        view.frame = .init(origin: .zero,
                           size: CGSize(width: 10,
                                        height: ViewSize.accessoryViewHeight))
        view.backgroundColor = .systemGray5
        return view
    }()
    
    let changeKeyboardButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 150, height: 150))
        let image = UIImage(systemName: "textformat.size",
                            withConfiguration: ViewSize.imageConfig)
        button.setImage(image, for: .normal)
        return button
    }()
    
    // MARK: ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        presenter.viewDidLoad(noteIndex: noteIndex)
        setupViews()
        navigationBarSetup()
    }
    // MARK: SetupViews
    func setupViews() {
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(textView)
        accessoryView.addSubview(changeKeyboardButton)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            contentView.heightAnchor.constraint(greaterThanOrEqualTo: scrollView.heightAnchor),
        ])
        
        textView.snp.makeConstraints { make in
            make.left.right.top.bottom.equalToSuperview()
        }
        textView.inputAccessoryView = accessoryView
        
        
        changeKeyboardButton.addTarget(self,
                                       action: #selector(switchKeyboard),
                                       for: .touchUpInside)
        changeKeyboardButton.snp.makeConstraints { make in
            make.left.right.top.bottom.equalToSuperview()
        }
        
    }
    
    func navigationBarSetup() {
        
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneAction))
        let add = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addImageToNote))
        let delete = noteIndex == nil ? UIBarButtonItem() : UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteNote))
        
        navigationItem.rightBarButtonItems = [done, add, delete]
    }
}

//MARK: Methods

extension DetailsScreenViewController {
    @objc func doneAction() {
        presenter.saveNote(attributedString: self.textView.attributedText,
                           screenshot: textView.screenShot(),
                           noteIndex: noteIndex)
    }
    
    @objc func deleteNote() {
        presenter.deleteNote(noteIndex: noteIndex!)
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            textView.contentInset = .zero
        } else {
            textView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }
        
        textView.scrollIndicatorInsets = textView.contentInset
        
        let selectedRange = textView.selectedRange
        textView.scrollRangeToVisible(selectedRange)
    }
}

//MARK: Stylekeyboard methods and implementation

extension DetailsScreenViewController {
    
    @objc func showStyleKeyboard() {
        let bottomSafeAreaInset = UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0.0
        let keyboardView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: textView.frame.width, height: ViewSize.keyboardSizeHeight + bottomSafeAreaInset)))
        keyboardView.backgroundColor = .tertiarySystemBackground
        
        keyboardView.addSubview(styleKeyboardService)
        styleKeyboardService.snp.makeConstraints { make in
            make.left.right.bottom.top.equalToSuperview()
        }
        
        keyboardView.layoutIfNeeded()
        textView.inputView = keyboardView //changes standart keyboard on custom
        textView.resignFirstResponder()
        textView.becomeFirstResponder()
    }
    
    @objc func showStandartKeyboard() {
        textView.inputView = nil
        textView.resignFirstResponder()
        textView.becomeFirstResponder()
    }
    
    @objc func switchKeyboard() {
        isStyleEditing.toggle()
        isStyleEditing ? showStyleKeyboard() :
        showStandartKeyboard()
    }
}

//MARK: Protocol implementation

extension DetailsScreenViewController: DetailsScreenProtocol {
    func success(attString: NSAttributedString) {
        self.textView.attributedText = attString
    }
    
    func failure() {
        print("Error")
    }
    
    
    func changeFont(attribute: Int) {
        textView.textFontChange(to: Fonts(rawValue: attribute) ?? .bold)
    }
    
    func changeSize(action: Int) {
        textView.changeFontSize(how: FontSize(rawValue: action) ?? .increase)
    }
    
}




//MARK: Pick and insert images
extension DetailsScreenViewController: PHPickerViewControllerDelegate {
    
    
    // opens image picker
    @objc func addImageToNote() {
        var config      = PHPickerConfiguration()
        config.filter   = .images
        let picker      = PHPickerViewController(configuration: config)
        picker.delegate = self
        config.selectionLimit = 1
        self.present(picker, animated: true)
    }
    
    //puts image in note
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        for result in results {
            result.itemProvider.loadObject(ofClass: UIImage.self,
                                           completionHandler: { (object, error) in
                
                if let image = object as? UIImage {
                    DispatchQueue.global().async { [ weak self] in
                        let textAttachment = NSTextAttachment()
                        let attString = NSMutableAttributedString(attachment: textAttachment)
                        
                        DispatchQueue.main.async {
                            
                            textAttachment.image = self?.resizeImage(width: Double(self?.textView.frame.size.width ?? 200),
                                                                     image: image)
                            self?.textView.textStorage.append(attString)
                            picker.dismiss(animated: true, completion: nil)
                            self?.textView.selectedRange.location += 1
                            
                        }
                    }
                }
            })
        }
    }
    
    //resizes images with original ratio based on image width
    private func resizeImage(width: Double, image: UIImage) -> UIImage {
        let scaleFactor     = image.size.height/image.size.width
        let newSize         = CGSize(width: width, height: width * scaleFactor)
        let rect            = CGRect(x: 0, y: 0, width: width, height: width * scaleFactor)
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        guard let newImage  = UIGraphicsGetImageFromCurrentImageContext() else { return UIImage() }
        UIGraphicsEndImageContext()
        return newImage
    }
    
    
}
