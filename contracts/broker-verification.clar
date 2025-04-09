;; broker-verification.clar
;; This contract validates licensed insurance professionals

(define-data-var admin principal tx-sender)

;; Map to store verified brokers
(define-map verified-brokers principal
  {
    license-number: (string-utf8 20),
    expiration: uint,
    state: (string-utf8 2),
    status: bool
  }
)

;; Add a new broker (only admin can do this)
(define-public (register-broker (broker principal) (license-number (string-utf8 20)) (expiration uint) (state (string-utf8 2)))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u100))
    (asserts! (is-none (map-get? verified-brokers broker)) (err u101))
    (ok (map-set verified-brokers broker {
      license-number: license-number,
      expiration: expiration,
      state: state,
      status: true
    }))
  )
)

;; Revoke broker verification
(define-public (revoke-broker (broker principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u100))
    (asserts! (is-some (map-get? verified-brokers broker)) (err u102))
    (match (map-get? verified-brokers broker)
      broker-data (ok (map-set verified-brokers broker
        (merge broker-data { status: false })))
      (err u102)
    )
  )
)

;; Check if a broker is verified
(define-read-only (is-verified (broker principal))
  (match (map-get? verified-brokers broker)
    broker-data (ok (get status broker-data))
    (err u102)
  )
)

;; Get broker details
(define-read-only (get-broker-details (broker principal))
  (map-get? verified-brokers broker)
)

;; Transfer admin rights
(define-public (transfer-admin (new-admin principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u100))
    (ok (var-set admin new-admin))
  )
)
