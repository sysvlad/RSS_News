
import SafariServices
import UIKit
import Foundation

public typealias VoidBlock = (() -> Void)

// Маркер для возврата к нужному экрану
public protocol OperationRootViewControllerProtocol {}

public protocol NavigationStackProvidable {
    var firstNavigationController: UINavigationController? { get }
}

// sourcery: AutoMockable, isOpen, rootDir = Router, path = /
public protocol BaseRouterInput: AnyObject {
    var sourceViewController: UIViewController? { get }
    init(viewController: UIViewController)

// MARK: - Navigation functions

    /// If there is a navigation controller, performs pop
    /// Otherwise invokes `dismiss()` on a source VC
    /// - Parameter animated: `true` if transition animation required, `false` otherwise. Defaults to `true`
    /// - Parameter force: Force dismiss modaly presented navigation controller instead of popping. Defaults to `false`
    /// - Parameter completion: Block invoked on transition end. Defaults to `nil`
    func dismiss(animated: Bool, force: Bool, completion: VoidBlock?)

    /// Performs pop to the first found VC of a given type, iterating stack top to bottom.
    /// - Parameter type: Type of a target VC to search
    /// - Parameter animated: `true` if transition animation required, `false` otherwise. Defaults to `true`
    /// - Parameter completion: Block invoked on transition end. Defaults to `nil`
    func pop(toTopVcOfType type: UIViewController.Type, animated: Bool, completion: VoidBlock?)

    /// If there is a navigation controller, performs pop to its root VC
    /// Otherwise does nothing
    /// - Parameter animated: `true` if transition animation required, `false` otherwise. Defaults to `true`
    func popToRoot(animated: Bool)

    /// If there is a navigation controller pushes a given VC to navigation stack
    /// Otherwise presents it modally
    /// - Parameter viewController: Target VC to show
    /// - Parameter context: some context object. Usage example - you might want to deliver transition style or some other transition related data. Defaults to `nil`
    /// - Parameter animated: `true` if transition animation required, `false` otherwise. Defaults to `true`
    /// - Parameter completion: Block invoked on transition end. Defaults to `nil`
    func show(_ viewController: UIViewController, context: Any?, animated: Bool, completion: VoidBlock?)

    /// Presents a given `viewController` modally
    /// - Parameter viewController: Target VC to present
    /// - Parameter context: some context object. Usage example - you might want to deliver transition style or some other transition related data. Defaults to `nil`
    /// - Parameter animated: `true` if transition animation required, `false` otherwise. Defaults to `true`
    /// - Parameter completion: Block invoked on transition end. Defaults to `nil`
    func present(_ viewController: UIViewController, context: Any?, animated: Bool, fullScreen: Bool, completion: VoidBlock?)

    /// Attempts to open a given URL
    /// - Parameter url: URL to be opened
    func openURL(_ url: URL)

    /// Attempts to open a given URL in internal screen
    /// - Parameter url: URL to be opened
    func presentSafariPage(_ url: URL)
}

// Provide default value for parameters
// Motivation: Want to have final methods in base router. Can't define method as final in protocol extension.
// Drawback: If method is not exist in class that conforms to protocol, then it will crash with BadExcess.
// https://medium.com/@georgetsifrikas/swift-protocols-with-default-values-b7278d3eef22
public extension BaseRouterInput {
    func dismiss(animated: Bool = true, force: Bool = false, completion: VoidBlock? = nil) {
        dismiss(animated: animated, force: force, completion: completion)
    }

    // periphery:ignore - Provide default value for parameters
    func pop<T: UIViewController>(toTopVcOfType type: T.Type, animated: Bool, completion: VoidBlock?) {
        pop(toTopVcOfType: type, animated: animated, completion: completion)
    }

    func popToRoot(animated: Bool = true) {
        popToRoot(animated: animated)
    }

    // periphery:ignore - Provide default value for parameters
    func show(_ viewController: UIViewController, context: Any? = nil, animated: Bool = true, completion: VoidBlock? = nil) {
        show(viewController, context: context, animated: animated, completion: completion)
    }

    func present(_ viewController: UIViewController, context: Any? = nil, animated: Bool = true, fullScreen: Bool = false, completion: VoidBlock? = nil) {
        present(viewController, context: context, animated: animated, fullScreen: fullScreen, completion: completion)
    }

    func openURL(_ url: URL) {
        openURL(url)
    }

    func presentSafariPage(_ url: URL) {
        presentSafariPage(url)
    }
}

///
open class BaseRouter: BaseRouterInput {

    public weak var sourceViewController: UIViewController?

    lazy var firstNavigationController: UINavigationController? = {
        UIApplication.shared.windows.first { $0.isKeyWindow } as! UINavigationController
    }()

    private var isPushing = false

    required public init(viewController: UIViewController) {
        sourceViewController = viewController
    }

    public required init() {}

    public final func dismiss(animated: Bool, force: Bool, completion: VoidBlock?) {
        if let nc = sourceViewController?.navigationController {
            if force {
                nc.dismiss(animated: animated, completion: completion)
            } else {
                CATransaction.begin()
                CATransaction.setCompletionBlock(completion)
                nc.popViewController(animated: animated)
                CATransaction.commit()
            }
        } else if sourceViewController?.presentingViewController != nil {
            sourceViewController?.dismiss(animated: animated, completion: completion)
        }
    }

    public final func pop(toTopVcOfType type: UIViewController.Type, animated: Bool, completion: VoidBlock?) {
        guard let nc = sourceViewController?.navigationController else {
            completion?()
            return
        }

        guard let targetVC = nc.viewControllers.last(where: { $0.isKind(of: type) }) else {
            completion?()
            return
        }

        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        nc.popToViewController(targetVC, animated: animated)
        CATransaction.commit()
    }

    public final func pop<T>(toTopVcOfProtocolType type: T.Type, animated: Bool, completion: VoidBlock?) {
        guard let nc = sourceViewController?.navigationController else {
            return
        }

        guard let targetVC = nc.viewControllers.first(where: { $0 is T }) else {
            popToRoot()
            return
        }

        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        nc.popToViewController(targetVC, animated: animated)
        CATransaction.commit()
    }

    public final func popToRoot(animated: Bool = true) {
        if let presentedViewController = sourceViewController?.presentedViewController {
            presentedViewController.dismiss(animated: true, completion: nil)
        }

        sourceViewController?.navigationController?.popToRootViewController(animated: animated)
    }

    public final func show(_ viewController: UIViewController, context: Any? = nil, animated: Bool = true, completion: VoidBlock? = nil) {
        if let navigationController = sourceViewController?.navigationController {
            push(viewController, on: navigationController, animated: animated, completion: completion)
        } else {
            present(viewController, context: context, animated: animated, completion: completion)
        }
    }

    public final func present(_ viewController: UIViewController, context: Any? = nil, animated: Bool = true, fullScreen: Bool = false, completion: VoidBlock? = nil) {
        if fullScreen {
            viewController.modalPresentationStyle = .overFullScreen
        }

        sourceViewController?.present(viewController, animated: animated, completion: completion)
    }

    public final func pushOnFirstNavigationController(
        _ viewController: UIViewController,
        animated: Bool = true,
        completion: VoidBlock? = nil
    ) {

        if let firstNavigationController = firstNavigationController {
            push(viewController, on: firstNavigationController, animated: animated, completion: completion)
        }
    }

    public final func removeAndPush(_ viewController: UIViewController, count: Int = 1, animated: Bool = true) {
        if let navigationController = firstNavigationController {
            var viewControllers = navigationController.viewControllers
            viewControllers.removeLast(count)
            viewControllers.append(viewController)
            navigationController.setViewControllers(viewControllers, animated: animated)
        }
    }

    public final func openURL(_ url: URL) {
        UIApplication.shared.open(url, options: [:])
    }

    public final func presentSafariPage(_ url: URL) {
        let vc = SFSafariViewController(url: url)
        present(vc, animated: true)
    }

    public final func popToOperationRootVC(animated: Bool) {
        guard let navigationController = sourceViewController?.navigationController,
              let rootVC = navigationController.viewControllers.last(where: { $0 is OperationRootViewControllerProtocol }) else {
            popToRoot(animated: animated)
            return
        }
        navigationController.popToViewController(rootVC, animated: true)
    }
}

// MARK: - Private methods

fileprivate extension BaseRouter {
    /// Used to reuse completion handler on `pushViewController` transition
    func push(_ viewController: UIViewController, on navigationController: UINavigationController, animated: Bool = true, completion: VoidBlock? = nil) {
        weak var weakSelf = self

        if !isPushing {
            isPushing = true

            CATransaction.begin()
            CATransaction.setCompletionBlock {
                weakSelf?.isPushing = false
                completion?()
            }

            navigationController.pushViewController(viewController, animated: animated)
            CATransaction.commit()
        }
    }
}
