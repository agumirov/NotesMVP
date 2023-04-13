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
                     DetailsScreenProtocol,
                     UITextViewDelegate,
                     ViewControllerProtocol {
    
    
    var presenter: DetailsScreenPresenterProtocol!
    var attString: NSAttributedString!
    var noteIndex: Int?
    var textView = UITextView()
    var isStyleEditing = false
    var styleKeyboardService: StyleKeyboardService!
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        presenter.viewDidLoad(noteIndex: noteIndex)
        setupViews()
    }
}

//MARK: Views setup

extension DetailsScreenViewController {
    
    func setupViews() {
        navigationBarSetup()
        textViewSetup()
        accessoryViewSetup()
    }
    
    func textViewSetup() {
        view.addSubview(textView)
        textView.snp.makeConstraints { make in
            make.left.right.top.bottom.equalToSuperview()
        }
        textView.inputAccessoryView = accessoryView
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
}

//MARK: Stylekeyboard methods and realization

extension DetailsScreenViewController {
    
    func accessoryViewSetup() {
        accessoryView.addSubview(changeKeyboardButton)
        
        changeKeyboardButton.snp.makeConstraints { make in
            make.left.right.top.bottom.equalToSuperview()
        }
        
        changeKeyboardButton.addTarget(self,
                                       action: #selector(switchKeyboard),
                                       for: .touchUpInside)
    }
    
    
    //add frame to make style keyboard's size equal to standart keyboard size
    //inserts style keyboard in textView
    
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

extension DetailsScreenViewController {
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
