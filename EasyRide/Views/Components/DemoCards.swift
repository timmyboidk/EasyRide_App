import SwiftUI

struct ServiceCard: View {
    let item: DemoItem
    var body: some View {
        Text(item.title)
    }
}

struct CompactServiceCard: View {
    let item: DemoItem
    var body: some View {
        Text(item.title)
    }
}

struct ResponsiveCard: View {
    let item: DemoItem
    var body: some View {
        Text(item.title)
    }
}
