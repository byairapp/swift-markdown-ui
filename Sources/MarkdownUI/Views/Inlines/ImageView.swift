import SwiftUI

struct ImageView: View {
    @Environment(\.theme.image) private var image
    @Environment(\.imageProvider) private var imageProvider
    @Environment(\.imageBaseURL) private var baseURL
    @Environment(\.onImageTap) private var onImageTap

    private let data: RawImageData

    init(data: RawImageData) {
        self.data = data
    }

    var body: some View {
        self.image.makeBody(
            configuration: .init(
                label: .init(self.label),
                content: .init(block: self.content)
            )
        )
    }

    private var label: some View {
        self.imageProvider.makeImage(url: self.url)
            .link(url: self.url, onTap: self.onImageTap)
            .accessibilityLabel(self.data.alt)
    }

    private var content: BlockNode {
        if let destination = self.data.destination {
            return .paragraph(
                content: [
                    .link(
                        destination: destination,
                        children: [.image(source: self.data.source, children: [.text(self.data.alt)])]
                    )
                ]
            )
        } else {
            return .paragraph(
                content: [.image(source: self.data.source, children: [.text(self.data.alt)])]
            )
        }
    }

    private var url: URL? {
        URL(string: self.data.source, relativeTo: self.baseURL)
    }
}

extension ImageView {
    init?(_ inlines: [InlineNode]) {
        guard inlines.count == 1, let data = inlines.first?.imageData else {
            return nil
        }
        self.init(data: data)
    }
}

extension View {
    fileprivate func link(url: URL?, onTap: ((URL?) -> Void)? = nil) -> some View {
        self.modifier(LinkModifier(url: url, onTap: onTap))
    }
}

extension Markdown {
    /// Sets a callback to be called when an image is tapped.
    /// - Parameter action: The callback to be called when an image is tapped.
    ///                     The callback receives the URL of the image that was tapped.
    /// - Returns: A view that calls the action when an image is tapped.
    public func markdownImageTapAction(_ action: @escaping (URL?) -> Void) -> some View {
        self.environment(\.onImageTap, action)
    }
}

private struct LinkModifier: ViewModifier {
    let url: URL?
    let onTap: ((URL?) -> Void)?

    func body(content: Content) -> some View {
        if let onTap = onTap {
            Button {
                onTap(url)
            } label: {
                content
            }
            .buttonStyle(.plain)
        } else {
            content
        }
    }
}
