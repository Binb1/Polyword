//
//  Translator.swift
//  Life-Translator
//
//  Created by Robin Champsaur on 14/06/2017.
//  Copyright © 2017 Robin Champsaur. All rights reserved.
//

import Foundation
import Alamofire
import SWXMLHash

class Translator {
    
    var token: String = ""
    var finalTranslationFirst = "Loading..."
    var finalTranslationSecond = "Loading..."
    
    /**
     Function fetching a translation token from Microsoft text translate API
     */
    @objc func getToken() {
        let url = "https://api.cognitive.microsoft.com/sts/v1.0/issueToken"
        let headers: HTTPHeaders = ["Ocp-Apim-Subscription-Key": ocpKey ]
        
        Alamofire.request(url, method: .post, headers: headers).response { response in
            print(response.error ?? "Error alamo")
            if response.error != nil {
                Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(self.getToken), userInfo: nil, repeats: false)
            } else{
                self.token = String(data: response.data!, encoding: String.Encoding.utf8) as String!
            }
        }
        
        Timer.scheduledTimer(timeInterval: 540, target: self, selector: #selector(self.getToken), userInfo: nil, repeats: false)
    }
    
    func relay(to: String, word: String, number: Int){
        if number == 1 {
            translate(to: to, word: word, saver: 1)
        } else {
            translate(to: to, word: word, saver: 2)
        }
    }
    
    /**
     Function translating the object's name (in english) detected by the neural network to the langagues chosen by the user
     */
    func translate(to: String, word: String, saver: Int) {
        if token.count > 0{
            //Building the url
            let url = "https://api.microsofttranslator.com/v2/http.svc/Translate?appid=Bearer%20" +
                self.token + "&text=the%20" + convertWordToTranslatorFormat(word: word) +
                "&from=en" + "&to=" + to
            
            //Analyzing the server answer
            Alamofire.request(url).response { response in
                if (response.error == nil){
                    let xml = SWXMLHash.parse(response.data!)
                    if saver == 1 {
                        self.finalTranslationFirst = xml["string"].element!.text
                    } else {
                        self.finalTranslationSecond = xml["string"].element!.text
                    }
                } else {
                    if saver == 1 {
                        self.finalTranslationFirst = "Error while translating"
                    } else {
                        self.finalTranslationSecond = "Error while translating"
                    }
                }
            }
        } else {
            if saver == 1 {
                self.finalTranslationFirst = "Error while translating"
            } else {
                self.finalTranslationSecond = "Error while translating"
            }
        }
    }
    
    func convertWordToTranslatorFormat(word: String) -> String {
        return word.replacingOccurrences(of: " ", with: "%20", options: .literal, range: nil)
    }
    
    /**
     Function returning translation results
     */
    func sendTranslateResult(saver: Int) -> String {
        if saver == 1 {
            return finalTranslationFirst
        } else {
            return finalTranslationSecond
            
        }
    }
    
    /**
     Function reseting the translation fields
     */
    func resetTranslation() {
        finalTranslationSecond = ""
        finalTranslationFirst = ""
    }
    
    
    /**
     Function going from a flag icon to its associated name in the Microsoft language API
     */
    func convertFlag(flag: String) -> String {
        //[ "🇫🇷", "🇬🇧", "🇪🇸", "🇩🇪",  "🇮🇹", "🇵🇱", "🇵🇹", "🇬🇷", "🇺🇸", "🇭🇹", "🇭🇷", "🇨🇿", "🇩🇰", "🇳🇱", "🇫🇮", "🇸🇪", "🇳🇴", "🇮🇱", "🇮🇳", "🇯🇵", "🇰🇷", "🇹🇭", "🇮🇩", "🇻🇳", "🇷🇺", "🇷🇸", "🇹🇷",  "🇺🇦", "🇸🇰", "🇸🇮",  "🇭🇺", "🇱🇹", "🇷🇴" ]
        //"🇫🇷", "🇬🇧", "🇪🇸", "🇩🇪",  "🇮🇹",  "🇵🇱", "🇵🇹", "🇬🇷" GOOD - DONE
        //"🇭🇷", "🇨🇿", "🇩🇰", "🇳🇱", "🇫🇮", "🇸🇪",  "🇳🇴", GOOD - DONE
        //"🇷🇺", "🇷🇸", "🇹🇷",  "🇺🇦", "🇸🇰", "🇸🇮",  "🇭🇺", "🇱🇹", "🇷🇴" GOOD - DONE
        //"🇮🇱", "🇮🇳", GOOD - DONE
        //"🇯🇵", "🇰🇷", "🇹🇭", "🇻🇳", "🇮🇩", GOOD - DONE
        //"🇺🇸", "🇭🇹", GOOD - DONE
        
        switch (flag) {
        //"🇫🇷", "🇬🇧", "🇪🇸", "🇩🇪",  "🇮🇹",  "🇵🇱", "🇵🇹", "🇬🇷"
        case "🇫🇷" :
            return "fr"
        case "🇬🇧" :
            return "en"
        case "🇪🇸" :
            return "es"
        case "🇩🇪" :
            return "de"
        case "🇮🇹" :
            return "it"
        case "🇵🇱" :
            return "pl"
        case "🇵🇹" :
            return "pt"
        case "🇬🇷" :
            return "el"
        //"🇭🇷", "🇨🇿", "🇩🇰", "🇳🇱", "🇫🇮", "🇸🇪",  "🇳🇴"
        case "🇭🇷" :
            return "hr"
        case "🇨🇿" :
            return "cs"
        case "🇩🇰" :
            return "da"
        case "🇳🇱" :
            return "nl"
        case "🇫🇮" :
            return "fi"
        case "🇸🇪" :
            return "sv"
        case "🇳🇴" :
            return "no"
        //"🇮🇱", "🇮🇳"
        case "🇮🇱" :
            return "he"
        case "🇮🇳" :
            return "hi"
        //"🇯🇵", "🇰🇷", "🇹🇭", "🇻🇳",  "🇮🇩",
        case "🇯🇵" :
            return "ja"
        case "🇨🇳" :
            return "zh-CHS"
        case "🇰🇷" :
            return "ko"
        case "🇹🇭" :
            return "th"
        case "🇻🇳" :
            return "vi"
        case "🇮🇩" :
            return "id"
        //"🇺🇸", "🇭🇹"
        case "🇺🇸" :
            return "en"
        case "🇭🇹" :
            return "ht"
        //"🇷🇺", "🇷🇸", "🇹🇷", "🇺🇦", "🇸🇰", "🇸🇮",  "🇭🇺", "🇱🇹", "🇷🇴" GOOD
        case "🇷🇺" :
            return "ru"
        case "🇷🇸" :
            return "sr-Latn"
        case "🇹🇷" :
            return "tr"
        case "🇺🇦" :
            return "uk"
        case "🇸🇰" :
            return "sk"
        case "🇸🇮" :
            return "sl"
        case "🇭🇺" :
            return "hu"
        case "🇱🇹" :
            return "lt"
        case "🇷🇴":
            return "ro"
            
        default:
            return "en"
        }
    }
}

