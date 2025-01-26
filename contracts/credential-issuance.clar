;; Credential Issuance Contract

(define-map credentials
  { credential-id: (string-ascii 64) }
  {
    institution: principal,
    recipient: principal,
    credential-type: (string-ascii 50),
    issue-date: uint,
    expiration-date: (optional uint),
    metadata: (string-utf8 256)
  }
)

(define-data-var credential-nonce uint u0)

(define-public (issue-credential
  (recipient principal)
  (credential-type (string-ascii 50))
  (expiration-date (optional uint))
  (metadata (string-utf8 256)))
  (let
    ((issuer tx-sender)
     (nonce (var-get credential-nonce))
     (credential-id (concat (concat (to-ascii (to-string nonce)) "-") (to-ascii (to-string issuer)))))
    (asserts! (is-eq contract-caller .institution-registry) (err u403))
    (map-set credentials
      { credential-id: credential-id }
      {
        institution: issuer,
        recipient: recipient,
        credential-type: credential-type,
        issue-date: block-height,
        expiration-date: expiration-date,
        metadata: metadata
      }
    )
    (var-set credential-nonce (+ nonce u1))
    (ok credential-id)
  )
)

(define-read-only (get-credential (credential-id (string-ascii 64)))
  (map-get? credentials { credential-id: credential-id })
)

(define-public (revoke-credential (credential-id (string-ascii 64)))
  (let
    ((credential (unwrap! (map-get? credentials { credential-id: credential-id }) (err u404))))
    (asserts! (is-eq tx-sender (get institution credential)) (err u403))
    (map-delete credentials { credential-id: credential-id })
    (ok true)
  )
)

