//
//  AVPlayer+Publisher.swift
//  movieApp
//
//  Created by Bjorn Bradley on 12/10/24.
//

import Foundation
import AVKit
import Combine

extension AVPlayer {
    func periodicTimeObserverPublisher(interval: CMTime) -> AnyPublisher<CMTime, Never> {
        let subject = PassthroughSubject<CMTime, Never>()
        let timeObserver = addPeriodicTimeObserver(forInterval: interval, queue: .main) { time in
            subject.send(time)
        }
        return subject.handleEvents(receiveCancel: { [weak self] in
            self?.removeTimeObserver(timeObserver)
        }).eraseToAnyPublisher()
    }
}
