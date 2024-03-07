import SwiftUI
import Stripe

struct StripePaymentCardView: View {
    var event: Event
    @Binding var isPresented: Bool
    @State private var paymentMethodParams: STPPaymentMethodParams?

    var body: some View {
        VStack {
            StripeCardFieldWrapper(paymentMethodParams: $paymentMethodParams)
                .frame(height: 50)
                .padding()

            Button("Pay \(event.costOfEntry) $") {
                if let paymentParams = paymentMethodParams {
                    processPayment(with: paymentParams)
                }
            }
            .disabled(paymentMethodParams == nil)
        }
    }

    private func processPayment(with paymentMethodParams: STPPaymentMethodParams) {
        // Implement your payment processing logic here
        // Interact with your backend to create and confirm a PaymentIntent
        // On successful payment:
        // self.isPresented = false
        // On failure, handle appropriately
    }
}

struct StripeCardFieldWrapper: UIViewControllerRepresentable {
    @Binding var paymentMethodParams: STPPaymentMethodParams?

    func makeUIViewController(context: Context) -> StripeCardInputViewController {
        let viewController = StripeCardInputViewController()
        viewController.cardField.delegate = context.coordinator
        return viewController
    }

    func updateUIViewController(_ uiViewController: StripeCardInputViewController, context: Context) {
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class StripeCardInputViewController: UIViewController {
        var cardField = STPPaymentCardTextField()

        override func viewDidLoad() {
            super.viewDidLoad()

            cardField.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(cardField)

            NSLayoutConstraint.activate([
                cardField.topAnchor.constraint(equalTo: view.topAnchor),
                cardField.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                cardField.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                cardField.heightAnchor.constraint(equalToConstant: 50)
            ])

            cardField.postalCodeEntryEnabled = false
        }
    }

    class Coordinator: NSObject, STPPaymentCardTextFieldDelegate {
        var parent: StripeCardFieldWrapper

        init(_ parent: StripeCardFieldWrapper) {
            self.parent = parent
        }

        func paymentCardTextFieldDidChange(_ textField: STPPaymentCardTextField) {
            if textField.isValid {
                let cardParams = STPPaymentMethodCardParams()
                cardParams.number = textField.cardNumber
                cardParams.expMonth = textField.expirationMonth as NSNumber
                cardParams.expYear = textField.expirationYear as NSNumber
                cardParams.cvc = textField.cvc

                parent.paymentMethodParams = STPPaymentMethodParams(card: cardParams, billingDetails: nil, metadata: nil)
            } else {
                parent.paymentMethodParams = nil
            }
        }
    }
}
