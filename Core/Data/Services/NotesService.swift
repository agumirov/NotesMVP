//
//  NotesService.swift
//  TestNotes
//
//  Created by G G on 01.04.2023.
//

import Foundation

protocol NotesServiceProtocol: AnyObject {
    var notes: [NoteModel] { get set }
    func saveNote(attributedString: NSAttributedString, screenshot: Data, noteIndex: Int?)
    func deleteNote(noteIndex: Int)
    func getNoteByIndex(noteIndex: Int, completion: @escaping (NSAttributedString) -> Void)
    func getAllNotes(completion: @escaping (Data) -> Void)
}

class NotesService: NotesServiceProtocol {
    
    
     
    let defaults = UserDefaults.standard
    
    var notes: [NoteModel] {
        
        get {
            if let data = defaults.value(forKey: "notes") as? Data {
                guard let note = try? PropertyListDecoder().decode([NoteModel].self,
                                                                   from: data) else { return []}
                return note
            } else {
                return []
            }
        }
        
        set {
            if let data = try? PropertyListEncoder().encode(newValue) {
                defaults.set(data, forKey: "notes")
            }
        }
    }
    
    func getNoteByIndex(noteIndex: Int, completion: @escaping (NSAttributedString) -> Void) {
        if let note = try? NSAttributedString(data: self.notes[noteIndex].attString, documentAttributes: nil) {
            completion(note)
        }
    }
    
    func saveNote(attributedString: NSAttributedString,
                  screenshot: Data,
                  noteIndex: Int?) {
        
        if attributedString.string.isEmpty { return }
        
        let data = try! attributedString.data(from: NSRange(location: 0,
                                                            length: attributedString.length),
                                              documentAttributes: [.documentType: NSAttributedString.DocumentType.rtfd])
        if noteIndex != nil {
            self.notes[noteIndex ?? 0] = NoteModel(attString: data,
                                              screenshot: screenshot)
        } else {
            self.notes.insert(NoteModel(attString: data,
                                        screenshot: screenshot), at: 0)
        }
    }
    
    func deleteNote(noteIndex: Int) {
        self.notes.remove(at: noteIndex)
    }
    
    func getAllNotes(completion: @escaping (Data) -> Void) {
        for note in self.notes {
            completion(note.screenshot)
        }
    }
}
