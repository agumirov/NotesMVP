//
//  textStyleService.swift
//  TestNotes
//
//  Created by G G on 11.03.2023.
//

import Foundation
import UIKit


extension UITextView {
    
    
    func changeFontSize(how: FontSize) {
        
        if selectedRange.length == 0 {
            return
        }
        
        let initialFont = textStorage.attribute(.font, at: selectedRange.location, effectiveRange: nil) as? UIFont ?? UIFont(descriptor: .init(), size: 15)
        let descriptor = initialFont.fontDescriptor
        let updatedFont = how == .increase ?
        UIFont(descriptor: descriptor, size: initialFont.pointSize + 2) :
        UIFont(descriptor: descriptor, size: initialFont.pointSize - 2)
        textStorage.enumerateAttribute(.font, in: selectedRange) { (_, range, stop) in
            textStorage.beginEditing()
            textStorage.addAttribute(.font, value: updatedFont, range: range)
            textStorage.endEditing()
        }
    }
    
    func screenShot() -> Data { //throw
        UIGraphicsBeginImageContextWithOptions(CGSize(width: self.bounds.width,
                                                      height: self.bounds.height),
                                               false, 1)
        
        isEditable = false
        backgroundColor = UIColor(red: 180/255, green: 194/255, blue: 211/255, alpha: 0.3)
        let rect = CGRect(x: 0, y: 0, width: frame.size.width,
                          height: frame.size.height * 0.5)
        scrollRectToVisible(rect, animated: false)
        guard let context = UIGraphicsGetCurrentContext() else { return Data() }
        layer.render(in: context)
        guard let screenshot = UIGraphicsGetImageFromCurrentImageContext() else { return Data() }
        UIGraphicsEndImageContext()
        guard let cgImage = screenshot.cgImage else { return Data() }
        let imageRef: CGImage = cgImage.cropping(to: rect)!
        let cropped = UIImage(cgImage: imageRef)
        
        guard let data = cropped.jpegData(compressionQuality: 0.5) else { return Data() }
        backgroundColor = .systemBackground
        return data
    }
    
    func textFontChange(to: Fonts) {
        
        if selectedRange.length == 0 {
            return
        }
        
        let range = selectedRange
        let underlined = textStorage.attribute(.underlineStyle, at: range.location, effectiveRange: nil) as? Int
        let strikethrough = textStorage.attribute(.strikethroughStyle, at: range.location, effectiveRange: nil) as? Int
        
        let initialFont = textStorage.attribute(.font, at: range.location, effectiveRange: nil) as? UIFont ?? UIFont(descriptor: .init(), size: 15)
        
        var currentTraits = initialFont.fontDescriptor.symbolicTraits
        let fontSize = initialFont.pointSize
        
        switch to {
        case .bold, .italic:
            let trait = to == .bold ? UIFontDescriptor.SymbolicTraits.traitBold :
            UIFontDescriptor.SymbolicTraits.traitItalic
            
            currentTraits.contains(trait) ?
            currentTraits.remove(trait) :
            currentTraits.update(with: trait)
            
            guard let descriptor = initialFont.fontDescriptor.withSymbolicTraits(currentTraits) else { return }
            
            let updateFont = UIFont(descriptor: descriptor,
                                    size: fontSize)
            
            textStorage.enumerateAttribute(.font, in: range) { (_, range, stop) in
                textStorage.beginEditing()
                textStorage.addAttribute(.font, value: updateFont, range: range)
                textStorage.endEditing()
            }
            
        case .underlined, .strikethrough:
            let style: NSAttributedString.Key = to == .underlined ? .underlineStyle :
                .strikethroughStyle
            let attribute = to == .underlined ? underlined : strikethrough
            attribute == NSUnderlineStyle.single.rawValue ?
            textStorage.enumerateAttribute(style, in: range,
                                           options: .longestEffectiveRangeNotRequired,
                                           using: { (_, range, stop) in
                textStorage.beginEditing()
                textStorage.removeAttribute(style, range: range)
                textStorage.endEditing()
            }) :
            textStorage.enumerateAttribute(style, in: range,
                                           options: .longestEffectiveRangeNotRequired,
                                           using: { (_, range, stop) in
                textStorage.beginEditing()
                textStorage.addAttribute(style, value: NSUnderlineStyle.single.rawValue, range: range)
                textStorage.endEditing()
            })
            
            
        }
    }
    
}

enum Fonts: Int {
    case bold
    case italic
    case underlined
    case strikethrough
}

enum FontSize: Int {
    case increase
    case decrease
}
