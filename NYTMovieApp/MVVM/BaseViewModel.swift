import Foundation

protocol BaseViewModelProtocol: BaseViewModel {
    associatedtype ReloadType
    var reloadWith: ((ReloadType) -> Void)? { get set }
}

class BaseViewModel { }
