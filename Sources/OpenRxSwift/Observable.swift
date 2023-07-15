//
//  File.swift
//  
//
//  Created by James Tang on 15/7/2023.
//

import Foundation

public class Observable<T> {
    let subject: PublishedSubject<T>

    static func from(_ t: T) -> Observable<T> {
        return .init(subject: PublishedSubject(t))
    }

    public init(subject: PublishedSubject<T>) {
        self.subject = subject
    }
}
