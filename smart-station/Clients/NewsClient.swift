import ComposableArchitecture
import Foundation

@DependencyClient
struct NewsClient: Sendable {
    var fetchTopHeadlines: @Sendable () async throws -> [NewsArticle]
}

extension NewsClient: DependencyKey {
    static let liveValue = NewsClient(
        fetchTopHeadlines: {
            let url = URL(string: "https://news.google.com/rss?hl=ja&gl=JP&ceid=JP:ja")!
            let (data, _) = try await URLSession.shared.data(from: url)
            return try GoogleNewsRSSParser.parse(data: data)
        }
    )
}

extension DependencyValues {
    var newsClient: NewsClient {
        get { self[NewsClient.self] }
        set { self[NewsClient.self] = newValue }
    }
}

// MARK: - RSS XML Parser

private enum GoogleNewsRSSParser {
    static func parse(data: Data) throws -> [NewsArticle] {
        let delegate = RSSParserDelegate()
        let parser = XMLParser(data: data)
        parser.delegate = delegate
        guard parser.parse() else {
            throw NSError(domain: "RSSParser", code: -1, userInfo: [
                NSLocalizedDescriptionKey: "Failed to parse RSS feed"
            ])
        }
        return delegate.articles
    }
}

private final class RSSParserDelegate: NSObject, XMLParserDelegate, @unchecked Sendable {
    var articles: [NewsArticle] = []

    private var isInsideItem = false
    private var currentElement = ""
    private var currentTitle = ""
    private var currentLink = ""
    private var currentPubDate = ""
    private var currentSource = ""
    private var currentDescription = ""

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss zzz"
        return formatter
    }()

    func parser(_ parser: XMLParser, didStartElement elementName: String,
                namespaceURI: String?, qualifiedName: String?,
                attributes: [String: String] = [:]) {
        currentElement = elementName
        if elementName == "item" {
            isInsideItem = true
            currentTitle = ""
            currentLink = ""
            currentPubDate = ""
            currentSource = ""
            currentDescription = ""
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        guard isInsideItem else { return }
        switch currentElement {
        case "title":
            currentTitle += string
        case "link":
            currentLink += string
        case "pubDate":
            currentPubDate += string
        case "source":
            currentSource += string
        case "description":
            currentDescription += string
        default:
            break
        }
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String,
                namespaceURI: String?, qualifiedName: String?) {
        guard elementName == "item" else { return }
        isInsideItem = false

        // Limit to 20 articles
        guard articles.count < 20 else { return }

        let title = currentTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        let link = currentLink.trimmingCharacters(in: .whitespacesAndNewlines)
        let source = currentSource.trimmingCharacters(in: .whitespacesAndNewlines)
        let description = Self.stripHTML(currentDescription.trimmingCharacters(in: .whitespacesAndNewlines))
        let pubDate = currentPubDate.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !title.isEmpty, let url = URL(string: link) else { return }

        let date = Self.dateFormatter.date(from: pubDate) ?? Date()

        let article = NewsArticle(
            title: title,
            description: description,
            source: source.isEmpty ? "Google News" : source,
            url: url,
            publishedAt: date
        )
        articles.append(article)
    }

    private static func stripHTML(_ string: String) -> String {
        string.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
            .replacingOccurrences(of: "&amp;", with: "&")
            .replacingOccurrences(of: "&lt;", with: "<")
            .replacingOccurrences(of: "&gt;", with: ">")
            .replacingOccurrences(of: "&quot;", with: "\"")
            .replacingOccurrences(of: "&#39;", with: "'")
    }
}
