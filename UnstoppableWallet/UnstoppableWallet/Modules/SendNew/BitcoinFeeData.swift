import BigInt
import EvmKit
import Foundation
import MarketKit

struct BitcoinFeeData {
    let fee: Decimal

    init(fee: Decimal) {
        self.fee = fee
    }

    func amountData(feeToken: Token, currency: Currency, feeTokenRate: Decimal?) -> AmountData? {
        let coinValue = CoinValue(kind: .token(token: feeToken), value: fee)
        let currencyValue = feeTokenRate.map { CurrencyValue(currency: currency, value: fee * $0) }

        return AmountData(coinValue: coinValue, currencyValue: currencyValue)
    }
}