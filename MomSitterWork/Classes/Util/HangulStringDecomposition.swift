//
//  HangulStringDecomposition.swift
//  MomSitterWork
//
//  Created by Dong-Eon Kim on 2020/12/19.
//  Copyright © 2020 Dong-Eon Kim. All rights reserved.
//

import Foundation

public class HangulStringDecomposition {
    private let startOfHangul: UInt32 = 44032
    private let endOfHangul: UInt32 = 55215
    private let initialConsonantArray = [
        "ㄱ", "ㄲ", "ㄴ", "ㄷ", "ㄸ", "ㄹ", "ㅁ", "ㅂ", "ㅃ", "ㅅ", "ㅆ", "ㅇ", "ㅈ", "ㅉ", "ㅊ", "ㅋ", "ㅌ", "ㅍ", "ㅎ"
    ]
    private let medialConsonantArray = [
        "ㅏ", "ㅐ", "ㅑ", "ㅒ", "ㅓ", "ㅔ", "ㅕ", "ㅖ", "ㅗ", "ㅘ", "ㅙ", "ㅚ", "ㅛ", "ㅜ", "ㅝ", "ㅞ", "ㅟ", "ㅠ", "ㅡ", "ㅢ", "ㅣ"
    ]
    private let finalConsonantArray = [
        " ", "ㄱ", "ㄲ", "ㄳ", "ㄴ", "ㄵ", "ㄶ", "ㄷ", "ㄹ", "ㄺ", "ㄻ", "ㄼ", "ㄽ", "ㄾ", "ㄿ", "ㅀ", "ㅁ", "ㅂ", "ㅄ", "ㅅ", "ㅆ", "ㅇ", "ㅈ", "ㅊ", "ㅋ", "ㅌ", "ㅍ", "ㅎ"
    ]
    
    public enum ConsonantType {
        case Initial
        case Medial
        case Final
    }
    
    public func getStringConsonant(string: String, consonantType: ConsonantType) -> String {
        return self._extractConsonantValue(string: string, consonantType: consonantType)
    }
    
    private func _extractConsonantValue(string: String, consonantType: ConsonantType) -> String {
        var resultString = String()
        
        for unicode in string.unicodeScalars {
            let currentUnicodeValue = unicode.value
            
            if ( startOfHangul <= currentUnicodeValue &&
                endOfHangul >= currentUnicodeValue ) {
                
                var currentCharacter: String!
                
                switch consonantType {
                case .Initial:
                    currentCharacter = initialConsonantArray[Int(((currentUnicodeValue - startOfHangul) / 28) / 21)]
                    break
                case .Medial:
                    currentCharacter = medialConsonantArray[Int(((currentUnicodeValue - startOfHangul) / 28) % 21)]
                    break
                case .Final:
                    currentCharacter = finalConsonantArray[Int((currentUnicodeValue - startOfHangul) % 28)]
                    break
                }
                
                resultString.append(currentCharacter)
                
            } else {
                if let scalar = UnicodeScalar(currentUnicodeValue) {
                    resultString.append(Character(scalar))
                }
            }
        }
        
        return resultString
    }
    
}
