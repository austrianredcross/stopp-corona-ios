//
//  String+URLEncoding.swift
//  CoronaContact
//

import Foundation

public extension String {
    /// Safely encodes strings that are used in the path of a request
    /// The path component of a URL is the component immediately following the host component (if present).
    /// It ends wherever the query or fragment component begins. For example, in the
    /// URL http://www.example.com/index.php?key1=value1, the path component is **/index.php**.
    var urlPathSafe: String? {
        addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)
    }

    /// Safely encodes strings that are used in the query of a request
    /// The query component of a URL is the component immediately following a question mark (?).
    /// For example, in the URL http://www.example.com/index.php?key1=value1#jumpLink,
    /// the query component is **key1=value1**.
    var urlQuerySafe: String? {
        addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    }
}
