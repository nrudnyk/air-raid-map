//
//  ImageActivityItemSource.swift
//  air-raid-map
//
//  Created by Nazar Rudnyk on 16.05.2022.
//

import UIKit
import LinkPresentation

class ImageActivityItemSource: NSObject, UIActivityItemSource {
    private let title: String
    private let text: String
    private let image: UIImage
    
    init(title: String, text: String, image: UIImage) {
        self.title = title
        self.text = text
        self.image = image
    }
    
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return title
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        return image
    }
    
    func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
        let metadata = LPLinkMetadata()
        metadata.imageProvider = NSItemProvider(object: image)
        metadata.title = title
        
        // This is a bit ugly, though I could not find other ways to show text content below title.
        // https://stackoverflow.com/questions/60563773/ios-13-share-sheet-changing-subtitle-item-description
        // You may need to escape some special characters like "/".
        metadata.originalURL = URL(fileURLWithPath: text)
        
        return metadata
    }
}
