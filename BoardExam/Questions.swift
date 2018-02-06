//
//  Questions.swift
//  PsychiatryQnA
//
//  Created by NohJaisung on 2018. 2. 5..
//  Copyright © 2018년 Hossam Ghareeb. All rights reserved.
//

import Foundation
import AVFoundation
import MediaPlayer

struct Questions {
   
    let questionDic: [String : Int] = ["1":1,"2":2,"3":3,"4":4,"5":5]
 
}

func makeQuestionCassette() -> (AVQueuePlayer?, [String:Int], [String]) {
    let questions = Questions()
    let questionDic = questions.questionDic
     let queplayer = AVQueuePlayer()
    let questionArray = uniqueRandoms(numberOfRandoms: questionDic.count, minNum: 1, maxNum: UInt32(questionDic.count))
    
    
    for item in questionArray {
        let urlPath = Bundle.main.path(forResource: item, ofType:"mp3")
        let fileURL = NSURL(fileURLWithPath:urlPath!)
        let playerItem = AVPlayerItem(url:fileURL as URL)
        queplayer.insert(playerItem, after:nil)
        
        
    }
   
    return (queplayer, questionDic, questionArray)
  
    
}

func uniqueRandoms(numberOfRandoms: Int, minNum: Int , maxNum: UInt32) -> [String] {
        var uniqueNumbers = Set<String>()
        while uniqueNumbers.count < numberOfRandoms {
            uniqueNumbers.insert(String(Int(arc4random_uniform(maxNum)) + minNum))
        }
        return Array(uniqueNumbers).shuffle
    }
      


extension Array {
    var shuffle:[Element] {
        var elements = self
        for index in 0..<elements.count {
            let anotherIndex = Int(arc4random_uniform(UInt32(elements.count-index)))+index
            if anotherIndex != index {
                elements.swapAt(index, anotherIndex)
            }
        }
        return elements
    }
}
