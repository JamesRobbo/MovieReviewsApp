import UIKit

class BaseViewController<ViewModel: BaseViewModelProtocol>: UIViewController {
    
    let viewModel: ViewModel
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.bind()
    }
    
    private func bind() {
        self.viewModel.reloadWith = { [weak self] type in
            DispatchQueue.main.async {
                self?.reload(type)
            }
        }
    }
    
    func reload(_ type: ViewModel.ReloadType) {
        // Override me
    }
}
