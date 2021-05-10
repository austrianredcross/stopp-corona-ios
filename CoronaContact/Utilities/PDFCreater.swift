//
//  PDFCreator.swift
//  CoronaContact
//

import Foundation
import PDFKit

class PDFCreator {
    
    let diaryDayInfo: [DiaryDayInfo]
    
    init(diary: [DiaryDayInfo]) {
        diaryDayInfo = diary
    }
    
    func convertToPDF() -> Data {
        
        let pdfMetaData = [kCGPDFContextCreator: "Österreichisches Rotes Kreuz"]
        
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let pageRect = CGRect(x: 0, y: 0, width: 595.2, height: 841.8) // A4, 72 dpi
        
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        let data = renderer.pdfData { (context) in
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .natural
            paragraphStyle.lineBreakMode = .byWordWrapping
            
            let textFont = UIFont.systemFont(ofSize: 12.0, weight: .regular)
            
            let textAttributes = [
                NSAttributedString.Key.paragraphStyle: paragraphStyle,
                NSAttributedString.Key.font: textFont,
            ]
            
            context.beginPage()
            
            var fullDiaryText = ""
            for oneDiaryDay in diaryDayInfo where !oneDiaryDay.diaryEntries.isEmpty {

                fullDiaryText += "\(oneDiaryDay.date.shortDayShortMonthLongYear): "
                
                for oneDiaryEntry in oneDiaryDay.diaryEntries {
                    
                    guard let diaryInformation = oneDiaryEntry?.diaryInformation else { continue }
                    
                    fullDiaryText += "\(diaryInformation.fullInfo);"
                }
                
                fullDiaryText += "\n\n"
                
            }
            
            let attributedText = NSAttributedString(string: fullDiaryText, attributes: textAttributes)
            
            let textRect = CGRect( x: 10, y: 10, width: pageRect.width - 20, height: pageRect.height - 10 - pageRect.height / 5.0)
            
            attributedText.draw(in: textRect)
        }
        
        return data
    }
}
