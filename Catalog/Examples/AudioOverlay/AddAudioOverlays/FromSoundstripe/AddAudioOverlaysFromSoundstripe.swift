import CoreMedia
import ImglyKit

class AddAudioOverlaysFromSoundstripeSwift: Example, VideoEditViewControllerDelegate {
  override func invokeExample() {
    // Create a `Video` from a URL to a video in the app bundle.
    let video = Video(url: Bundle.main.url(forResource: "Skater", withExtension: "mp4")!)

    // Create an instance of the custom `SoundstripeProvider`.
    let soundstripeProvider = SoundstripeProvider(baseURL: "YOUR_SOUNDSTRIPE_PROXY_ENDPOINT")

    // Since we created a custom `SoundstripeProvider`, we need to use the `AudioProviderCategory` instead of the
    // `SoundstripeAudioCategory`.
    let soundstripeCategory = AudioProviderCategory(identifier: "soundstripe_custom", title: "Soundstripe", imageURL: nil, audioProvider: soundstripeProvider)

    // Create a `Configuration` object.
    let configuration = Configuration { builder in
      // In this example we are using the default assets for the asset catalog as a base.
      // However, you can also create an empty catalog as well which only contains your
      // custom assets.
      let assetCatalog = AssetCatalog.defaultItems

      // Add the custom audio clips to the asset catalog.
      assetCatalog.audioClips = [soundstripeCategory]

      // Use the new asset catalog for the configuration.
      builder.assetCatalog = assetCatalog
    }

    // Create and present the video editor. Make this class the delegate of it to handle export and cancelation.
    let videoEditViewController = VideoEditViewController(videoAsset: video, configuration: configuration)
    videoEditViewController.delegate = self
    videoEditViewController.modalPresentationStyle = .fullScreen
    presentingViewController?.present(videoEditViewController, animated: true, completion: nil)
  }

  // MARK: - VideoEditViewControllerDelegate

  func videoEditViewControllerShouldStart(_ videoEditViewController: VideoEditViewController, task: VideoEditorTask) -> Bool {
    // Implementing this method is optional. You can perform additional validation and interrupt the process by returning `false`.
    true
  }

  func videoEditViewControllerDidFinish(_ videoEditViewController: VideoEditViewController, result: VideoEditorResult) {
    // The user exported a new video successfully and the newly generated video is located at `result.output.url`. Dismissing the editor.
    presentingViewController?.dismiss(animated: true, completion: nil)
  }

  func videoEditViewControllerDidFail(_ videoEditViewController: VideoEditViewController, error: VideoEditorError) {
    // There was an error generating the video.
    print(error.localizedDescription)
    // Dismissing the editor.
    presentingViewController?.dismiss(animated: true, completion: nil)
  }

  func videoEditViewControllerDidCancel(_ videoEditViewController: VideoEditViewController) {
    // The user tapped on the cancel button within the editor. Dismissing the editor.
    presentingViewController?.dismiss(animated: true, completion: nil)
  }
}

/// A `SoundstripeProvider` represents an entry point to the Soundstripe Audio API.
class SoundstripeProvider: NSObject {
  private static let timeout: TimeInterval = 15
  private static let version: String = "v1"

  private static let decoder: JSONDecoder = {
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    return decoder
  }()

  private enum Parameters: String {
    case pageSize = "page[size]"
    case pageNumber = "page[number]"
    case query = "filter[q]"
    case songs
  }

  let headers: [String: String]?
  let baseURL: String

  /// Creates an audio provider consuming Soundstripe Audio API.
  ///
  /// - Parameters:
  ///   - baseURL: The base URL of your endpoint.
  ///   - headers: The headers for the URL request.
  ///
  /// - Note: The `SoundstripeProvider` assumes that your endpoint is mirroring the official [Soundstripe API](https://docs.soundstripe.com).
  @objc(initWithBaseURL:headers:) public init(baseURL: String, headers: [String: String]? = nil) {
    self.baseURL = baseURL
    self.headers = headers
  }
}

// MARK: - AudioProvider

extension SoundstripeProvider: AudioProvider {
  func trending(offset: Int, limit: Int, completion: @escaping (Result<AudioProviderResult, Error>) -> Void) {
    let task = URLSession.shared.dataTask(with: request(query: nil, offset: offset, limit: limit)) { data, _, error in
      self.parse(data: data, offset: offset, limit: limit, error: error, completion: completion)
    }
    task.resume()
  }

  func search(query: String, offset: Int, limit: Int, completion: @escaping (Result<AudioProviderResult, Error>) -> Void) {
    let task = URLSession.shared.dataTask(with: request(query: query, offset: offset, limit: limit)) { data, _, error in
      self.parse(data: data, offset: offset, limit: limit, error: error, completion: completion)
    }
    task.resume()
  }

  func get(identifier: String, completion: @escaping (Result<AudioProviderResult, Error>) -> Void) {
    let task = URLSession.shared.dataTask(with: requestSong(identifier: identifier)) { data, _, error in
      self.parseSong(data: data, error: error, completion: completion)
    }
    task.resume()
  }

  private func request(query: String?, offset: Int, limit: Int) -> URLRequest {
    let url = URL(string: baseURL)!
      .appendingPathComponent(SoundstripeProvider.version)
      .appendingPathComponent(Parameters.songs.rawValue)

    var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)!
    urlComponents.queryItems = [
      URLQueryItem(name: Parameters.pageNumber.rawValue, value: String(offset)),
      URLQueryItem(name: Parameters.pageSize.rawValue, value: String(limit))
    ]

    if let query = query {
      urlComponents.queryItems?.append(URLQueryItem(name: Parameters.query.rawValue, value: query))
    }

    var request = URLRequest(url: urlComponents.url!, timeoutInterval: SoundstripeProvider.timeout)
    if let headers = headers {
      headers.forEach { header in
        request.setValue(header.value, forHTTPHeaderField: header.key)
      }
    }
    return request
  }

  private func requestSong(identifier: String) -> URLRequest {
    let url = URL(string: baseURL)!
      .appendingPathComponent(SoundstripeProvider.version)
      .appendingPathComponent(Parameters.songs.rawValue)

    let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)!
    var request = URLRequest(url: urlComponents.url!.appendingPathComponent(identifier))
    if let headers = headers {
      headers.forEach { header in
        request.setValue(header.value, forHTTPHeaderField: header.key)
      }
    }
    return request
  }

  private func parseSong(data: Data?, error: Error?, completion: @escaping (Result<AudioProviderResult, Error>) -> Void) {
    if let error = error {
      completion(.failure(error))
      return
    }

    guard let data = data else {
      completion(.success(AudioProviderResult(audioClips: [])))
      return
    }

    do {
      let response = try SoundstripeProvider.decoder.decode(SoundStripeSongResponse.self, from: data)
      let audioClip = AudioClip(data: response.data, included: response.included)
      let result = AudioProviderResult(audioClips: [audioClip].compactMap { $0 })
      completion(.success(result))
    } catch {
      completion(.failure(error))
    }
  }

  private func parse(data: Data?, offset: Int, limit: Int, error: Error?, completion: @escaping (Result<AudioProviderResult, Error>) -> Void) {
    if let error = error {
      completion(.failure(error))
      return
    }

    guard let data = data else {
      completion(.success(AudioProviderResult(audioClips: [])))
      return
    }

    do {
      let response = try SoundstripeProvider.decoder.decode(SoundstripeQueryResponse.self, from: data)
      let result = AudioProviderResult(response: response, offset: offset, limit: limit)
      completion(.success(result))
    } catch {
      completion(.failure(error))
    }
  }
}

// MARK: - Extensions

extension AudioProviderResult {
  convenience init(response: SoundstripeQueryResponse, offset: Int, limit: Int) {
    var audioClips: [AudioClip] = []

    for item in response.data {
      if let audioClip = AudioClip(data: item, included: response.included) {
        audioClips.append(audioClip)
      }
    }

    let currentCount = max(1, offset) * limit
    let totalCount = response.links.meta.totalCount
    let hasMore = totalCount > currentCount

    self.init(audioClips: audioClips, hasMore: hasMore)
  }
}

extension AudioClip {
  convenience init?(data: SoundstripeSong, included: [SoundstripeIncluded]) {
    func link(for identifiers: [String], in links: [SoundstripeIncluded]) -> [SoundstripeIncluded]? {
      links.filter { identifiers.contains($0.id) }
    }

    if let id = data.relationships.audioFiles?.data.first?.id,
       let artist = data.relationships.artists?.data.map(\.id),
       let songLink = link(for: [id], in: included),
       let artistLink = link(for: artist, in: included),
       let audio = songLink.first,
       let mp3 = audio.attributes.versions?.mp3,
       let url = URL(string: mp3) {
      var name: String?
      var thumbnail: URL?

      artistLink.forEach { arti in
        if let new = arti.attributes.name {
          if let previous = name {
            name = "\(previous), \(new)"
          } else {
            name = new
            if let image = arti.attributes.image {
              thumbnail = URL(string: image)
            }
          }
        }
      }

      self.init(identifier: "soundstripe_song_\(data.id)", audioURL: url, title: data.attributes.title, artist: name, thumbnailURL: thumbnail, duration: CMTime(seconds: audio.attributes.duration ?? 0, preferredTimescale: 90000), resolver: SoundstripeResolver.identifier)
      accessibilityLabel = data.attributes.title
    } else {
      return nil
    }
  }
}

// MARK: - Soundstripe Decodables

/// The Soundstripe response for retrieving a single song.
struct SoundStripeSongResponse: Decodable {
  let data: SoundstripeSong
  let included: [SoundstripeIncluded]
}

/// The Soundstripe response for a query..
struct SoundstripeQueryResponse: Decodable {
  let data: [SoundstripeSong]
  let links: SoundstripeLinks
  let included: [SoundstripeIncluded]
}

/// The Soundstripe song object.
struct SoundstripeSong: Decodable {
  let id: String
  let type: String
  let relationships: SoundstripeSongRelationships
  let attributes: SoundstripeSongAttributes
}

/// Attributes of a Soundstripe song.
struct SoundstripeSongAttributes: Decodable {
  let title: String
}

/// Relationships of a Soundstripe song.
struct SoundstripeSongRelationships: Decodable {
  let audioFiles: SoundstripeRelationshipContainer?
  let artists: SoundstripeRelationshipContainer?
}

/// Conainer including the data of Soundstripe relationships.
struct SoundstripeRelationshipContainer: Decodable {
  let data: [SoundstripeRelationshipData]
}

/// The data containted in Soundstripe relationship objects.
struct SoundstripeRelationshipData: Decodable {
  let id: String
  let type: String
}

/// The included data of a Soundstripe response.
struct SoundstripeIncluded: Decodable {
  let attributes: SounstripeSongAttributes
  let id: String
  let type: String
}

/// The attributes of a Soundstripe song.
struct SounstripeSongAttributes: Decodable {
  let songId: String?
  let duration: Double?
  let versions: SoundstripeSongVersions?
  let name: String?
  let image: String?
}

/// The different file versions of a song.
struct SoundstripeSongVersions: Decodable {
  let mp3: String
}

/// Links of a Soundstripe query response.
struct SoundstripeLinks: Decodable {
  let meta: SoundstripeMetadata
}

/// Metadata of a Soundstripe query response.
struct SoundstripeMetadata: Decodable {
  let totalCount: Int
}

/// An `AssetResolver` for Soundstripe.
class SoundstripeResolver: NSObject, AssetResolver {
  /// The identifier of this resolver.
  static let identifier = "my_soundstripe_asset_resolver"

  /// The `SoundstripeProvider` responsible for fetching the song for deserialization.
  let provider: SoundstripeProvider

  /// Initializes a new `SoundstripeResolver` from a provider.
  ///
  /// - Parameters:
  ///   - provider: The `SoundstripeProvider` responsible for fetching the song for deserialization.
  required init(provider: SoundstripeProvider) {
    self.provider = provider
  }

  /// Deserializes the custom asset.
  ///
  /// - Parameters:
  ///   - data: The data to deserialize the asset from.
  func deserialize(from data: [String: String], completion: @escaping (ResolvableAsset?) -> Void) {
    guard let id = data["id"] else {
      completion(nil)
      return
    }

    provider.get(identifier: id) { result in
      switch result {
      case .success(let result):
        if let audioClip = result.audioClips.first {
          completion(audioClip)
        } else {
          completion(nil)
        }
        return
      case .failure(let error):
        MasterLogger.error(error.localizedDescription)
        completion(nil)
        return
      }
    }
  }

  /// Serializes a custom asset.
  ///
  /// - Parameters:
  ///   - asset: The `ResolvableAsset` that should be serialized.
  func serialize(_ asset: ResolvableAsset) -> [String: String]? {
    if let audioClip = asset as? AudioClip {
      return ["id": audioClip.identifier.replacingOccurrences(of: "soundstripe_song_", with: "")]
    }
    return nil
  }
}
