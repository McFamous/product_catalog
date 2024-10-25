import Foundation

//Extension to format double to string with certain number of decimal places
extension Double {
    func toString(places: Int) -> String {
        let divisor = pow(10.0, Double(places))
        let newValue = (self * divisor).rounded() / divisor

        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: newValue)) ?? ""
    }
}
