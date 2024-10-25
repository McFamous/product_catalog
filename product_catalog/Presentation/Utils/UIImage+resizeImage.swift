import UIKit

extension UIImage {
    // method to resize an image to the specified CGSize
    func resizeImage(scaledTo size: CGSize) -> UIImage {
        // start a new graphic context with the required dimensions
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        // draw current image in a given rectangular area of ​​the new size
        self.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        // extract the image from the current context, completing it
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        // return the new image (along with force unwrap, since nil is unlikely)
        return image!
    }
}
