import Foundation

/// Encapsulates all the authentication logic for web views.
///
/// This objects is in charge of deciding when a web view should be authenticated,
/// and rewriting requests to do so.
///
/// Our current authentication system is based on posting to wp-login.php and
/// taking advantage of the `redirect_to` parameter. In the specific case of
/// WordPress.com, we sometimes want to pre-authenticate the user when visiting
/// URLs that we're not sure if they are hosted there (e.g. mapped domains).
///
/// Since WordPress.com doesn't allow redirects to external URLs, we use a
/// special WordPress.com URL that includes the target URL, and extract that on
/// `interceptRedirect(request:)`. You should call that from your web view's
/// delegate method, when deciding if a request or redirect should continue.
///
class WebViewAuthenticator: NSObject {
    private let credentials: Credentials

    /// If true, the authenticator will assume that redirect URLs are allowed and
    /// won't use the special WordPress.com redirect URL
    ///
    var safeRedirect = false

    init(credentials: Credentials) {
        self.credentials = credentials
    }

    /// Potentially rewrites a request for authentication.
    ///
    /// This method will call the completion block with the request to be used.
    ///
    /// - Warning: On WordPress.com, this uses a special redirect system. It
    /// requires the web view to call `interceptRedirect(request:)` before
    /// loading any request.
    ///
    /// - Parameters:
    ///     - url: the URL to be loaded.
    ///     - cookieJar: a CookieJar object where the authenticator will look
    ///     for existing cookies.
    ///     - completion: this will be called with either the request for
    ///     authentication, or a request for the original URL.
    ///
    @objc func request(url: URL, cookieJar: CookieJar, completion: @escaping (URLRequest) -> Void) {
        cookieJar.hasCookie(url: loginURL, username: username) { [weak self] (hasCookie) in
            guard let authenticator = self else {
                return
            }

            let request = authenticator.request(url: url, authenticated: !hasCookie)
            completion(request)
        }
    }

    /// Intercepts and rewrites any potential redirect after login.
    ///
    /// This should be called whenever a web view needs to decide if it should
    /// load a request. If this returns a non-nil value, the resulting request
    /// should be loaded instead.
    ///
    /// - Parameters:
    ///     - request: the request that was going to be loaded by the web view.
    ///
    /// - Returns: a request to be loaded instead. If `nil`, the original
    /// request should continue loading.
    ///
    @objc func interceptRedirect(request: URLRequest) -> URLRequest? {
        guard let url = request.url,
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
            components.scheme == "https",
            components.host == "wordpress.com",
            let encodedRedirect = components
                .queryItems?
                .first(where: { $0.name == WebViewAuthenticator.redirectParameter })?
                .value,
            let redirect = encodedRedirect.removingPercentEncoding,
            let redirectUrl = URL(string: redirect) else {
                return nil
        }

        return URLRequest(url: redirectUrl)
    }

    /// Rewrites a request for authentication.
    ///
    /// This method will always return an authenticated request. If you want to
    /// authenticate only if needed, by inspecting the existing cookies, use
    /// request(url:cookieJar:completion:) instead
    ///
    func authenticatedRequest(url: URL) -> URLRequest {
        var request = URLRequest(url: loginURL)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = body(url: url)
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        return request
    }
}

private extension WebViewAuthenticator {
    func request(url: URL, authenticated: Bool) -> URLRequest {
        if authenticated {
            return authenticatedRequest(url: url)
        } else {
            return unauthenticatedRequest(url: url)
        }
    }

    func unauthenticatedRequest(url: URL) -> URLRequest {
        return URLRequest(url: url)
    }

    func body(url: URL) -> Data? {
        guard let redirectedUrl = redirectUrl(url: url.absoluteString) else {
                return nil
        }
        var parameters = [URLQueryItem]()
        parameters.append(URLQueryItem(name: "log", value: username))
//        if let password = password {
//            parameters.append(URLQueryItem(name: "pwd", value: password))
//        }
        parameters.append(URLQueryItem(name: "rememberme", value: "true"))
        parameters.append(URLQueryItem(name: "redirect_to", value: redirectedUrl))
        var components = URLComponents()
        components.queryItems = parameters

        return components.percentEncodedQuery?.data(using: .utf8)
    }

    func redirectUrl(url: String) -> String? {
        guard let escapedUrl = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
            !safeRedirect else {
            return url
        }

        return self.url(string: "https://wordpress.com/", parameters: [WebViewAuthenticator.redirectParameter: escapedUrl])?.absoluteString
    }

    func url(string: String, parameters: [String: String]) -> URL? {
        guard var components = URLComponents(string: string) else {
            return nil
        }
        components.queryItems = parameters.map({ (key, value) in
            return URLQueryItem(name: key, value: value)
        })
        return components.url
    }

    var username: String {
        return credentials.username
    }

    var authToken: String {
        return credentials.authToken
    }

    var loginURL: URL {
        return WebViewAuthenticator.wordPressComLoginUrl
    }

    static let wordPressComLoginUrl = URL(string: "https://wordpress.com/wp-login.php")!
    static let redirectParameter = "wpios_redirect"
}
