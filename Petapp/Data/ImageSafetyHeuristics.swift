import Foundation
import UIKit

#if canImport(Vision)
import Vision
#endif

struct ImageSafetyHeuristics {
    func detectLabels(from imageData: Data) -> [String] {
        guard let image = UIImage(data: imageData),
              let cgImage = image.cgImage else {
            return []
        }

        #if canImport(Vision)
        var labels: [String] = []
        let request = VNClassifyImageRequest { request, _ in
            guard let observations = request.results as? [VNClassificationObservation] else { return }
            labels = observations
                .filter { $0.confidence >= 0.2 }
                .prefix(8)
                .map { $0.identifier }
        }
        let handler = VNImageRequestHandler(cgImage: cgImage)
        do {
            try handler.perform([request])
            return labels
        } catch {
            return []
        }
        #else
        return []
        #endif
    }
}
