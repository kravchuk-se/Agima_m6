
import UIKit

protocol SongTableViewCellDelegate: AnyObject {
    func songTableViewCell(_ cell: SongTableViewCell, didPressButton downloadButton: DownloadButton)
}

class SongTableViewCell: UITableViewCell {

    @IBOutlet weak var songTitleLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var downloadButton: DownloadButton!
    
    weak var delegate: SongTableViewCellDelegate?
    
    
    @IBAction func buttonPressed(_ sender: DownloadButton) {
        delegate?.songTableViewCell(self, didPressButton: sender)
    }
    
}
