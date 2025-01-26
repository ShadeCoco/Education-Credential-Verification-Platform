;; Access Management Contract

(define-map authorized-issuers principal bool)

(define-data-var contract-owner principal tx-sender)

(define-public (set-contract-owner (new-owner principal))
  (let ((current-owner (var-get contract-owner)))
    (asserts! (is-eq tx-sender current-owner) (err u403))
    (var-set contract-owner new-owner)
    (ok true)
  )
)

(define-public (add-authorized-issuer (issuer principal))
  (let ((current-owner (var-get contract-owner)))
    (asserts! (is-eq tx-sender current-owner) (err u403))
    (map-set authorized-issuers issuer true)
    (ok true)
  )
)

(define-public (remove-authorized-issuer (issuer principal))
  (let ((current-owner (var-get contract-owner)))
    (asserts! (is-eq tx-sender current-owner) (err u403))
    (map-delete authorized-issuers issuer)
    (ok true)
  )
)

(define-read-only (is-authorized-issuer (issuer principal))
  (default-to false (map-get? authorized-issuers issuer))
)

