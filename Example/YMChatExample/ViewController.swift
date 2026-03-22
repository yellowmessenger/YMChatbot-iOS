import UIKit
import YMChat

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "YMChat Example"
        view.backgroundColor = .systemBackground

        let launchButton = UIButton(type: .system)
        launchButton.setTitle("Launch Bot", for: .normal)
        launchButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        launchButton.addTarget(self, action: #selector(launchBot), for: .touchUpInside)
        launchButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(launchButton)

        NSLayoutConstraint.activate([
            launchButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            launchButton.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    @objc private func launchBot() {
        let config = YMConfig(botId: "YOUR_BOT_ID")
        config.version = 3
        // config.ymAuthenticationToken = "YOUR_TOKEN"
        // config.payload = ["key": "value"]

        YMChat.shared.config = config
        YMChat.shared.enableLogging = true

        do {
            try YMChat.shared.startChatbot(on: self)
        } catch {
            print("Failed to start chatbot: \(error.localizedDescription)")
        }
    }
}
