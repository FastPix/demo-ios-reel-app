import Foundation
import SwiftUI
import UniformTypeIdentifiers

struct CustomMovieFile: Transferable {

    let url: URL

    @available(iOS 16.0, *)
    static var transferRepresentation: some TransferRepresentation {

        FileRepresentation(
            contentType: .movie
        ) { movie in

            SentTransferredFile(movie.url)

        } importing: { received in

            let fileName = received.file.lastPathComponent

            let destination = URL
                .temporaryDirectory
                .appendingPathComponent(fileName)
            
            if FileManager.default.fileExists(
                atPath: destination.path
            ) {

                try? FileManager.default.removeItem(
                    at: destination
                )
            }

            try FileManager.default.copyItem(
                at: received.file,
                to: destination
            )

            return Self(url: destination)
        }
    }
}
