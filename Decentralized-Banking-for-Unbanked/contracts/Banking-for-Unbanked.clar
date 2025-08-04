;; Decentralized Banking for Unbanked - Smart Contract
;; Version: 1.0.0
;; Author: DeFi Banking Team

;; Constants
(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u100))
(define-constant ERR_INSUFFICIENT_BALANCE (err u101))
(define-constant ERR_INVALID_AMOUNT (err u102))
(define-constant ERR_ACCOUNT_NOT_FOUND (err u103))
(define-constant ERR_LOAN_NOT_FOUND (err u104))
(define-constant ERR_LOAN_ALREADY_PAID (err u105))
(define-constant MIN_DEPOSIT u1000000) ;; 1 STX minimum
(define-constant INTEREST_RATE u5) ;; 5% annual interest
(define-constant LOAN_COLLATERAL_RATIO u150) ;; 150% collateralization

;; Data Variables
(define-data-var total-deposits uint u0)
(define-data-var total-loans uint u0)
(define-data-var loan-counter uint u0)

;; Data Maps
(define-map user-accounts 
  principal 
  {
    balance: uint,
    savings-balance: uint,
    created-at: uint,
    last-activity: uint
  }
)

(define-map user-loans
  {user: principal, loan-id: uint}
  {
    amount: uint,
    collateral: uint,
    interest-rate: uint,
    created-at: uint,
    due-date: uint,
    is-paid: bool
  }
)

(define-map savings-accounts
  principal
  {
    balance: uint,
    interest-earned: uint,
    last-interest-block: uint
  }
)

;; Private Functions
(define-private (calculate-interest (amount uint) (blocks-passed uint))
  (/ (* amount INTEREST_RATE blocks-passed) (* u365 u144)) ;; Daily interest approximation
)

(define-private (is-valid-amount (amount uint))
  (>= amount MIN_DEPOSIT)
)

;; Public Functions

;; Create Account
(define-public (create-account)
  (let 
    (
      (account-exists (map-get? user-accounts tx-sender))
    )
    (if (is-some account-exists)
      (err u106) ;; Account already exists
      (begin
        (map-set user-accounts tx-sender
          {
            balance: u0,
            savings-balance: u0,
            created-at: block-height,
            last-activity: block-height
          }
        )
        (ok true)
      )
    )
  )
)

;; Deposit STX
(define-public (deposit (amount uint))
  (let
    (
      (current-account (unwrap! (map-get? user-accounts tx-sender) ERR_ACCOUNT_NOT_FOUND))
      (new-balance (+ (get balance current-account) amount))
    )
    (if (is-valid-amount amount)
      (begin
        (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
        (map-set user-accounts tx-sender
          (merge current-account 
            {
              balance: new-balance,
              last-activity: block-height
            }
          )
        )
        (var-set total-deposits (+ (var-get total-deposits) amount))
        (print {event: "deposit", user: tx-sender, amount: amount, new-balance: new-balance})
        (ok new-balance)
      )
      ERR_INVALID_AMOUNT
    )
  )
)

;; Withdraw STX
(define-public (withdraw (amount uint))
  (let
    (
      (current-account (unwrap! (map-get? user-accounts tx-sender) ERR_ACCOUNT_NOT_FOUND))
      (current-balance (get balance current-account))
    )
    (if (>= current-balance amount)
      (begin
        (try! (as-contract (stx-transfer? amount tx-sender tx-sender)))
        (map-set user-accounts tx-sender
          (merge current-account 
            {
              balance: (- current-balance amount),
              last-activity: block-height
            }
          )
        )
        (var-set total-deposits (- (var-get total-deposits) amount))
        (print {event: "withdrawal", user: tx-sender, amount: amount, remaining-balance: (- current-balance amount)})
        (ok (- current-balance amount))
      )
      ERR_INSUFFICIENT_BALANCE
    )
  )
)

;; Open Savings Account
(define-public (open-savings-account (initial-amount uint))
  (let
    (
      (current-account (unwrap! (map-get? user-accounts tx-sender) ERR_ACCOUNT_NOT_FOUND))
      (current-balance (get balance current-account))
    )
    (if (>= current-balance initial-amount)
      (begin
        (map-set user-accounts tx-sender
          (merge current-account 
            {
              balance: (- current-balance initial-amount),
              savings-balance: (+ (get savings-balance current-account) initial-amount),
              last-activity: block-height
            }
          )
        )
        (map-set savings-accounts tx-sender
          {
            balance: initial-amount,
            interest-earned: u0,
            last-interest-block: block-height
          }
        )
        (print {event: "savings-opened", user: tx-sender, amount: initial-amount})
        (ok initial-amount)
      )
      ERR_INSUFFICIENT_BALANCE
    )
  )
)

;; Apply for Loan
(define-public (apply-loan (loan-amount uint) (collateral-amount uint))
  (let
    (
      (current-account (unwrap! (map-get? user-accounts tx-sender) ERR_ACCOUNT_NOT_FOUND))
      (required-collateral (/ (* loan-amount LOAN_COLLATERAL_RATIO) u100))
      (loan-id (+ (var-get loan-counter) u1))
    )
    (if (and 
          (>= collateral-amount required-collateral)
          (>= (get balance current-account) collateral-amount)
        )
      (begin
        ;; Lock collateral
        (map-set user-accounts tx-sender
          (merge current-account 
            {
              balance: (- (get balance current-account) collateral-amount),
              last-activity: block-height
            }
          )
        )
        ;; Create loan record
        (map-set user-loans 
          {user: tx-sender, loan-id: loan-id}
          {
            amount: loan-amount,
            collateral: collateral-amount,
            interest-rate: INTEREST_RATE,
            created-at: block-height,
            due-date: (+ block-height u52560), ;; ~1 year in blocks
            is-paid: false
          }
        )
        ;; Transfer loan amount to user
        (try! (as-contract (stx-transfer? loan-amount tx-sender tx-sender)))
        (var-set loan-counter loan-id)
        (var-set total-loans (+ (var-get total-loans) loan-amount))
        (print {event: "loan-approved", user: tx-sender, loan-id: loan-id, amount: loan-amount, collateral: collateral-amount})
        (ok loan-id)
      )
      ERR_INSUFFICIENT_BALANCE
    )
  )
)

;; Repay Loan
(define-public (repay-loan (loan-id uint))
  (let
    (
      (loan-key {user: tx-sender, loan-id: loan-id})
      (loan-data (unwrap! (map-get? user-loans loan-key) ERR_LOAN_NOT_FOUND))
      (loan-amount (get amount loan-data))
      (collateral (get collateral loan-data))
      (blocks-passed (- block-height (get created-at loan-data)))
      (interest (calculate-interest loan-amount blocks-passed))
      (total-repayment (+ loan-amount interest))
      (current-account (unwrap! (map-get? user-accounts tx-sender) ERR_ACCOUNT_NOT_FOUND))
    )
    (if (get is-paid loan-data)
      ERR_LOAN_ALREADY_PAID
      (begin
        ;; Transfer repayment from user
        (try! (stx-transfer? total-repayment tx-sender (as-contract tx-sender)))
        ;; Mark loan as paid and return collateral
        (map-set user-loans loan-key
          (merge loan-data {is-paid: true})
        )
        (map-set user-accounts tx-sender
          (merge current-account 
            {
              balance: (+ (get balance current-account) collateral),
              last-activity: block-height
            }
          )
        )
        (var-set total-loans (- (var-get total-loans) loan-amount))
        (print {event: "loan-repaid", user: tx-sender, loan-id: loan-id, total-paid: total-repayment, interest: interest})
        (ok total-repayment)
      )
    )
  )
)

;; Calculate and Claim Savings Interest
(define-public (claim-savings-interest)
  (let
    (
      (savings-data (unwrap! (map-get? savings-accounts tx-sender) ERR_ACCOUNT_NOT_FOUND))
      (current-account (unwrap! (map-get? user-accounts tx-sender) ERR_ACCOUNT_NOT_FOUND))
      (blocks-passed (- block-height (get last-interest-block savings-data)))
      (interest-earned (calculate-interest (get balance savings-data) blocks-passed))
    )
    (if (> interest-earned u0)
      (begin
        (map-set savings-accounts tx-sender
          (merge savings-data 
            {
              interest-earned: (+ (get interest-earned savings-data) interest-earned),
              last-interest-block: block-height
            }
          )
        )
        (map-set user-accounts tx-sender
          (merge current-account 
            {
              balance: (+ (get balance current-account) interest-earned),
              last-activity: block-height
            }
          )
        )
        (print {event: "interest-claimed", user: tx-sender, interest: interest-earned})
        (ok interest-earned)
      )
      (ok u0)
    )
  )
)

;; Read-only Functions

;; Get Account Balance
(define-read-only (get-balance (user principal))
  (match (map-get? user-accounts user)
    account (ok (get balance account))
    ERR_ACCOUNT_NOT_FOUND
  )
)

;; Get Savings Balance
(define-read-only (get-savings-balance (user principal))
  (match (map-get? savings-accounts user)
    savings (ok (get balance savings))
    (ok u0)
  )
)

;; Get Loan Details
(define-read-only (get-loan-details (user principal) (loan-id uint))
  (map-get? user-loans {user: user, loan-id: loan-id})
)

;; Get Total Platform Stats
(define-read-only (get-platform-stats)
  {
    total-deposits: (var-get total-deposits),
    total-loans: (var-get total-loans),
    active-loans: (var-get loan-counter)
  }
)