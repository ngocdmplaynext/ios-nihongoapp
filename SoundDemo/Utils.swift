//
//  Utils.swift
//  SoundDemo
//
//  Created by ngocdm on 2/22/17.
//  Copyright © 2017 ngocdm. All rights reserved.
//

public func heightForView(text:String, font:UIFont, width:CGFloat) -> CGFloat{
    let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
    label.numberOfLines = 0
    label.lineBreakMode = NSLineBreakMode.byWordWrapping
    label.font = font
    label.text = text
    
    label.sizeToFit()
    return label.frame.height
}

func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    let documentsDirectory = paths[0]
    return documentsDirectory
}

func cleanDocumentsDirectory() {
    let fileManager = FileManager.default
    let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    do {
        let filePaths = try fileManager.contentsOfDirectory(atPath: path)
        for filePath in filePaths {
            if filePath.contains("recording") {
                try fileManager.removeItem(atPath: path + "/" + filePath)
            }
        }
    } catch {
        print("Could not clear document folder: \(error)")
    }
}

func arrayCrossJoin<A, B, R>(
    aArray: [A],
    bArray: [B],
    joiner: (_ a: A, _ b: B) -> R?)
    -> [R]
{
    var results = [R]()
    for a in aArray
    {
        for b in bArray
        {
            if let result = joiner(a, b)
            {
                results.append(result)
            }
        }
    }
    return results
}
