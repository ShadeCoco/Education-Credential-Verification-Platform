;; Credential Management Contract

(define-data-var next-credential-id uint u0)

(define-map credentials
  { credential-id: uint }
  {
    issuer: principal,
    recipient: principal,
    credential-type: (string-ascii 50),
    issue-date: uint,
    expiration-date: (optional uint),
    metadata: (string-utf8 500)
  }
)

(define-public (issue-credential
    (recipient principal)
    (credential-type (string-ascii 50))
    (expiration-date (optional uint))
    (metadata (string-utf8 500)))
  (let
    ((new-id (var-get next-credential-id))
     (issuer tx-sender))
    (map-insert credentials
      { credential-id: new-id }
      {
        issuer: issuer,
        recipient: recipient,
        credential-type: credential-type,
        issue-date: block-height,
        expiration-date: expiration-date,
        metadata: metadata
      }
    )
    (var-set next-credential-id (+ new-id u1))
    (ok new-id)
  )
)

(define-read-only (get-credential (credential-id uint))
  (map-get? credentials { credential-id: credential-id })
)

(define-public (revoke-credential (credential-id uint))
  (let ((issuer tx-sender))
    (match (map-get? credentials { credential-id: credential-id })
      credential (begin
        (asserts! (is-eq issuer (get issuer credential)) (err u403))
        (map-delete credentials { credential-id: credential-id })
        (ok true)
      )
      (err u404)
    )
  )
)

