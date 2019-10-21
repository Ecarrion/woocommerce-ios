import Gridicons
import UIKit

/// A full-width banner view to be shown at the top of a tab below the navigation bar.
/// Consists of an icon, text label, action button and dismiss button.
///
final class TopBannerView: UIView {
    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView(image: nil)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var infoLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var dismissButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var actionButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let onDismiss: () -> Void
    private let onAction: () -> Void

    init(viewModel: TopBannerViewModel) {
        onDismiss = viewModel.dismissHandler
        onAction = viewModel.actionHandler
        super.init(frame: .zero)
        configureSubviews()
        configureSubviews(viewModel: viewModel)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TopBannerView {
    fileprivate func configureSubviews() {
        configureBackground()

        let contentView = createContentView()
        let contentContainerView = createContentContainerView(contentView: contentView)
        let topLevelView = createTopLevelView(contentContainerView: contentContainerView)
        addSubview(topLevelView)
        pinSubviewToAllEdges(topLevelView)

        titleLabel.applyHeadlineStyle()
        titleLabel.numberOfLines = 0

        infoLabel.applyBodyStyle()
        infoLabel.numberOfLines = 0

        dismissButton.setImage(Gridicon.iconOfType(.cross, withSize: CGSize(width: 24, height: 24)), for: .normal)
        dismissButton.tintColor = StyleManager.wooGreyTextMin
        dismissButton.addTarget(self, action: #selector(onDismissButtonTapped), for: .touchUpInside)

        actionButton.applyLinkButtonStyle()
        actionButton.addTarget(self, action: #selector(onActionButtonTapped), for: .touchUpInside)
    }

    fileprivate func configureSubviews(viewModel: TopBannerViewModel) {
        if let title = viewModel.title, !title.isEmpty {
            titleLabel.text = title
        } else {
            // It is necessary to remove the subview when no text, otherwise the stack view spacing stays.
            titleLabel.removeFromSuperview()
        }

        if let infoText = viewModel.infoText, !infoText.isEmpty {
            infoLabel.text = infoText
        } else {
            // It is necessary to remove the subview when no text, otherwise the stack view spacing stays.
            infoLabel.removeFromSuperview()
        }

        iconImageView.image = viewModel.icon

        actionButton.setTitle(viewModel.actionButtonTitle, for: .normal)
    }

    fileprivate func configureBackground() {
        backgroundColor = .white
    }

    fileprivate func createContentView() -> UIView {
        let textStackView = UIStackView(arrangedSubviews: [titleLabel, infoLabel])
        textStackView.translatesAutoresizingMaskIntoConstraints = false
        textStackView.axis = .vertical
        textStackView.spacing = 3

        iconImageView.setContentHuggingPriority(.required, for: .horizontal)
        iconImageView.setContentCompressionResistancePriority(.required, for: .horizontal)
        dismissButton.setContentHuggingPriority(.required, for: .horizontal)
        dismissButton.setContentCompressionResistancePriority(.required, for: .horizontal)

        let contentStackView = UIStackView(arrangedSubviews: [iconImageView, textStackView, dismissButton])
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.axis = .horizontal
        contentStackView.spacing = 10
        contentStackView.alignment = .leading
        return contentStackView
    }

    fileprivate func createContentContainerView(contentView: UIView) -> UIView {
        let contentContainerView = UIView(frame: .zero)
        contentContainerView.translatesAutoresizingMaskIntoConstraints = false
        contentContainerView.addSubview(contentView)
        contentContainerView.pinSubviewToAllEdges(contentView, insets: UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 10))
        return contentContainerView
    }

    fileprivate func createTopLevelView(contentContainerView: UIView) -> UIView {
        let stackView = UIStackView(arrangedSubviews: [contentContainerView, createBorderView(), actionButton, createBorderView()])
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }

    fileprivate func createBorderView() -> UIView {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = StyleManager.wooGreyBorder
        NSLayoutConstraint.activate(
            [
                view.heightAnchor.constraint(equalToConstant: 1),
            ])
        return view
    }
}

extension TopBannerView {
    @objc private func onDismissButtonTapped() {
        onDismiss()
    }

    @objc private func onActionButtonTapped() {
        onAction()
    }
}
