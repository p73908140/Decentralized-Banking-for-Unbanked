# Decentralized Banking for Unbanked

A comprehensive smart contract solution built on Stacks blockchain that provides essential banking services to unbanked populations through decentralized finance (DeFi) infrastructure.

##  Features

### Core Banking Services
- **Account Creation**: Simple onboarding process for new users
- **Deposits & Withdrawals**: Secure STX token handling with minimum deposit requirements
- **Savings Accounts**: Interest-bearing savings with automated interest calculation
- **Micro-loans**: Collateralized lending with flexible repayment terms
- **Transaction History**: Complete audit trail through blockchain events

### Advanced Features
- **Interest Calculation**: Dynamic interest earning on savings accounts
- **Collateralized Lending**: 150% collateralization ratio for loan security
- **Platform Statistics**: Real-time tracking of total deposits and loans
- **Event Logging**: Comprehensive transaction logging for transparency

##  Getting Started

### Prerequisites
- Stacks wallet (Hiro Wallet, Xverse, etc.)
- STX tokens for transactions
- Access to Stacks testnet or mainnet

### Deployment
```bash
# Deploy to testnet
clarinet deploy --testnet

# Deploy to mainnet
clarinet deploy --mainnet
```

##  Contract Functions

### Public Functions

#### Account Management
- `create-account()` - Creates a new user account
- `deposit(amount)` - Deposits STX tokens to account
- `withdraw(amount)` - Withdraws STX tokens from account

#### Savings Operations
- `open-savings-account(initial-amount)` - Opens interest-bearing savings
- `claim-savings-interest()` - Claims accumulated interest

#### Lending Services
- `apply-loan(loan-amount, collateral-amount)` - Applies for collateralized loan
- `repay-loan(loan-id)` - Repays loan with interest

### Read-Only Functions
- `get-balance(user)` - Returns user's account balance
- `get-savings-balance(user)` - Returns savings account balance
- `get-loan-details(user, loan-id)` - Returns loan information
- `get-platform-stats()` - Returns platform-wide statistics

##  Economics

### Interest Rates
- **Savings Interest**: 5% annual rate
- **Loan Interest**: 5% annual rate
- **Minimum Deposit**: 1 STX (1,000,000 microSTX)

### Loan Parameters
- **Collateral Ratio**: 150% (user must provide 1.5x collateral)
- **Loan Duration**: ~1 year (52,560 blocks)
- **Interest Calculation**: Daily compounding

##  Security Features

### Error Handling
- `ERR_UNAUTHORIZED` (100) - Access control violations
- `ERR_INSUFFICIENT_BALANCE` (101) - Insufficient funds
- `ERR_INVALID_AMOUNT` (102) - Invalid transaction amounts
- `ERR_ACCOUNT_NOT_FOUND` (103) - Account doesn't exist
- `ERR_LOAN_NOT_FOUND` (104) - Loan record not found
- `ERR_LOAN_ALREADY_PAID` (105) - Loan already repaid

### Safety Mechanisms
- Minimum deposit requirements
- Collateral lock during loan period
- Automated interest calculations
- Comprehensive input validation

##  Usage Examples

### Creating an Account and Making First Deposit
```clarity
;; Create account
(contract-call? .defi-banking create-account)

;; Deposit 5 STX
(contract-call? .defi-banking deposit u5000000)
```

### Opening Savings Account
```clarity
;; Open savings with 3 STX
(contract-call? .defi-banking open-savings-account u3000000)

;; Claim interest after some time
(contract-call? .defi-banking claim-savings-interest)
```

### Taking a Loan
```clarity
;; Apply for 2 STX loan with 3 STX collateral
(contract-call? .defi-banking apply-loan u2000000 u3000000)

;; Repay loan with ID 1
(contract-call? .defi-banking repay-loan u1)
```

##  Impact for Unbanked Population

### Accessibility
- **No Traditional Banking**: Access financial services without bank accounts
- **Global Reach**: Available 24/7 worldwide with internet connection
- **Low Barriers**: Minimal requirements for account creation

### Financial Inclusion
- **Savings Opportunities**: Earn interest on saved funds
- **Credit Access**: Obtain loans through collateralization
- **Financial Growth**: Build financial history and assets

### Transparency
- **Open Source**: All code publicly verifiable
- **Blockchain Records**: Immutable transaction history
- **Fair Terms**: Transparent interest rates and fees

##  Development

### Testing
```bash
# Run unit tests
clarinet test

# Check contract syntax
clarinet check
```

### Local Development
```bash
# Start local devnet
clarinet integrate

# Deploy locally
clarinet deploy --devnet
```

##  Platform Statistics

The contract tracks key metrics:
- Total deposits across all users
- Total outstanding loans
- Number of active loans
- Platform growth metrics

##  Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open Pull Request

##  License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

##  Support

For support and questions:
- Create an issue in the GitHub repository
- Join our community Discord
- Check the documentation wiki

##  Roadmap

### Phase 1 (Current)
- ✅ Basic banking operations
- ✅ Savings accounts with interest
- ✅ Collateralized lending
- ✅ Transaction logging

### Phase 2 (Planned)
- 🔄 Multi-token support
- 🔄 Credit scoring system
- 🔄 Peer-to-peer lending
- 🔄 Mobile app integration

### Phase 3 (Future)
- 🔄 Insurance products
- 🔄 Investment pools
- 🔄 Cross-chain compatibility
- 🔄 Governance token

## 📞 Contact

- **Team**: DeFi Banking Team
- **Email**: contact@defibanking.io
- **Website**: https://defibanking.io
- **Twitter**: @DeFiBankingTeam
