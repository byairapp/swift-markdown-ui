import SwiftUI

struct InlineText: View {
  @Environment(\.inlineImageProvider) private var inlineImageProvider
  @Environment(\.baseURL) private var baseURL
  @Environment(\.imageBaseURL) private var imageBaseURL
  @Environment(\.softBreakMode) private var softBreakMode
  @Environment(\.theme) private var theme
  @Environment(\.onImageTap) private var onImageTap

  @State private var inlineImages: [String: Image] = [:]

  private let inlines: [InlineNode]

  init(_ inlines: [InlineNode]) {
    self.inlines = inlines
  }

  var body: some View {
    TextStyleAttributesReader { attributes in
      if self.hasTappableImages {
        // Use ImageView-based rendering for tappable images
        self.renderWithImageViewSupport(attributes: attributes)
      } else {
        // Use existing Text-based rendering for better performance
        self.inlines.renderText(
          baseURL: self.baseURL,
          textStyles: .init(
            code: self.theme.code,
            emphasis: self.theme.emphasis,
            strong: self.theme.strong,
            strikethrough: self.theme.strikethrough,
            link: self.theme.link
          ),
          images: self.inlineImages,
          softBreakMode: self.softBreakMode,
          attributes: attributes
        )
      }
    }
    .task(id: self.inlines) {
      self.inlineImages = (try? await self.loadInlineImages()) ?? [:]
    }
  }

  // Check if we have any images that need tap support
  private var hasTappableImages: Bool {
    self.onImageTap != nil && !self.inlines.filter({ $0.imageData != nil }).isEmpty
  }

  // Render using ImageView for tap support (similar to ImageFlow approach)
    private func renderWithImageViewSupport(attributes: AttributeContainer) -> some View {
        let spacing = RelativeSize.rem(0.25).points(relativeTo: attributes.fontProperties)

        if #available(iOS 16.0, *) {
            return FlowLayout(horizontalSpacing: spacing, verticalSpacing: spacing) {
                configureInlines(attributes: attributes)
            }
        } else {
            return HStack {
                configureInlines(attributes: attributes)
            }
        }
    }

    private func configureInlines(attributes: AttributeContainer) -> some View {
        ForEach(Array(self.inlines.enumerated()), id: \.offset) { index, inline in
            switch inline {
            case .image:
                if let imageData = inline.imageData {
                    ImageView(data: imageData)
                }
            default:
                self.inlines[index...index].renderText(
                    baseURL: self.baseURL,
                    textStyles: .init(
                        code: self.theme.code,
                        emphasis: self.theme.emphasis,
                        strong: self.theme.strong,
                        strikethrough: self.theme.strikethrough,
                        link: self.theme.link
                    ),
                    images: self.inlineImages,
                    softBreakMode: self.softBreakMode,
                    attributes: attributes
                )
            }
        }
    }

  private func loadInlineImages() async throws -> [String: Image] {
    let images = Set(self.inlines.compactMap(\.imageData))
    guard !images.isEmpty else { return [:] }

    return try await withThrowingTaskGroup(of: (String, Image).self) { taskGroup in
      for image in images {
        guard let url = URL(string: image.source, relativeTo: self.imageBaseURL) else {
          continue
        }

        taskGroup.addTask {
          (image.source, try await self.inlineImageProvider.image(with: url, label: image.alt))
        }
      }

      var inlineImages: [String: Image] = [:]

      for try await result in taskGroup {
        inlineImages[result.0] = result.1
      }

      return inlineImages
    }
  }
}

