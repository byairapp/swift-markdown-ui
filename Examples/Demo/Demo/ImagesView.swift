import MarkdownUI
import SwiftUI

struct ImagesView: View {
  private let content = """
    ### Line R2 Nord\n\nAirport T2 → Clot d'Aragó\n\n### 💶 Buy a ticket\n**Price**: 4,60€\n\n### ⏰ Work hours\n05:42 AM - 11:38 PM \n\n### ✋ Good to know\n\nThe train station at Barcelona Airport is conveniently located 200m outside terminal building 2.\n\nChildren under 4 years old travel for free.\n\nOnly the R2 Nord offers a straight connection to the city.\n\n![Map BCN](https://byair-prod-bucket.fra1.cdn.digitaloceanspaces.com/ExtendedTransportDescriptionImages/BCN/BCN-Rodalies-R2-Nord-MOB-TABLET.png)\n\n![Logo](https://byair-prod-bucket.fra1.cdn.digitaloceanspaces.com/ExtendedTransportDescriptionImages/BCN/R2N_barcelona.svg.png)\n
    """

  private let inlineImageContent = """
    You can also insert images in a line of text, such as
    ![](https://picsum.photos/id/237/50/25) or
    ![](https://picsum.photos/id/433/50/25).

    ```
    You can also insert images in a line of text, such as
    ![](https://picsum.photos/id/237/50/25) or
    ![](https://picsum.photos/id/433/50/25).
    ```

    Note that MarkdownUI **cannot** apply any styling to
    inline images.

    ― Photos by André Spieker and Thomas Lefebvre
    """

  var body: some View {
    DemoView {
      Markdown(self.content)
            .markdownImageTapAction { url in
                print(url)
            }

      Section("Inline images") {
        Markdown(self.inlineImageContent)
      }

      Section("Customization Example") {
        Markdown(self.content)
      }
      .markdownBlockStyle(\.image) { configuration in
        configuration.label
          .clipShape(RoundedRectangle(cornerRadius: 8))
          .shadow(radius: 8, y: 8)
          .markdownMargin(top: .em(1.6), bottom: .em(1.6))
      }
    }
  }
}

struct ImagesView_Previews: PreviewProvider {
  static var previews: some View {
    ImagesView()
  }
}
