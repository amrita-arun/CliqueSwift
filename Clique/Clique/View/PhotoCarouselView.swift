//
//  PhotoCarouselView.swift
//  Clique
//
//  Created by Amrita Arun on 5/6/25.
//

import SwiftUI
import UIKit

/// A SwiftUI wrapper around a UIPageViewController for swiping through images.
struct PhotoCarouselView: UIViewControllerRepresentable {
    let imageURLs: [String]
    @Binding var currentPage: Int

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIPageViewController {
        let pvc = UIPageViewController(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal,
            options: nil
        )
        pvc.dataSource = context.coordinator
        pvc.delegate   = context.coordinator
        context.coordinator.setupControllers()

        // start at the current page
        if let first = context.coordinator.controllers.first {
            pvc.setViewControllers([first], direction: .forward, animated: false)
        }
        return pvc
    }

    func updateUIViewController(_ pvc: UIPageViewController, context: Context) {
        // if SwiftUI changes currentPage, jump there
        let idx = currentPage
        guard idx < context.coordinator.controllers.count else { return }
        let target = context.coordinator.controllers[idx]
        pvc.setViewControllers([target], direction: .forward, animated: true)
    }

    // MARK: - Coordinator

    class Coordinator: NSObject, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
        var parent: PhotoCarouselView
        var controllers: [UIViewController] = []
        var pageControlCurrent = 0

        init(_ parent: PhotoCarouselView) {
            self.parent = parent
        }

        /// Create a simple UIViewController per image URL
        func setupControllers() {
            controllers = parent.imageURLs.map { urlStr in
                let vc = UIViewController()
                let imgV = UIImageView()
                imgV.contentMode = .scaleAspectFill
                imgV.clipsToBounds = true

                // load image async
                if let url = URL(string: urlStr) {
                    URLSession.shared.dataTask(with: url) { data, _, _ in
                        if let d = data, let img = UIImage(data: d) {
                            DispatchQueue.main.async {
                                imgV.image = img
                            }
                        }
                    }.resume()
                }

                vc.view.addSubview(imgV)
                imgV.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    imgV.topAnchor.constraint(equalTo: vc.view.topAnchor),
                    imgV.bottomAnchor.constraint(equalTo: vc.view.bottomAnchor),
                    imgV.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor),
                    imgV.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor),
                ])
                return vc
            }
        }

        // MARK: UIPageViewControllerDataSource

        func pageViewController(
            _ pvc: UIPageViewController,
            viewControllerBefore vc: UIViewController
        ) -> UIViewController? {
            guard let idx = controllers.firstIndex(of: vc), idx > 0 else { return nil }
            return controllers[idx - 1]
        }

        func pageViewController(
            _ pvc: UIPageViewController,
            viewControllerAfter vc: UIViewController
        ) -> UIViewController? {
            guard let idx = controllers.firstIndex(of: vc),
                  idx + 1 < controllers.count else { return nil }
            return controllers[idx + 1]
        }

        // MARK: UIPageViewControllerDelegate

        func pageViewController(
            _ pvc: UIPageViewController,
            didFinishAnimating finished: Bool,
            previousViewControllers: [UIViewController],
            transitionCompleted completed: Bool
        ) {
            guard completed,
                  let visible = pvc.viewControllers?.first,
                  let idx = controllers.firstIndex(of: visible)
            else { return }
            pageControlCurrent = idx
            parent.currentPage = idx
        }
    }
}
