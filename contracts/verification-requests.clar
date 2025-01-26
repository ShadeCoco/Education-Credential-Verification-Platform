;; Verification Requests Contract

(define-data-var next-request-id uint u0)

(define-map verification-requests
  { request-id: uint }
  {
    requester: principal,
    credential-id: uint,
    status: (string-ascii 20),
    request-date: uint,
    response-date: (optional uint)
  }
)

(define-public (submit-verification-request (credential-id uint))
  (let
    ((new-id (var-get next-request-id))
     (requester tx-sender))
    (map-insert verification-requests
      { request-id: new-id }
      {
        requester: requester,
        credential-id: credential-id,
        status: "pending",
        request-date: block-height,
        response-date: none
      }
    )
    (var-set next-request-id (+ new-id u1))
    (ok new-id)
  )
)

(define-public (respond-to-verification-request (request-id uint) (is-verified bool))
  (let
    ((request (unwrap! (map-get? verification-requests { request-id: request-id }) (err u404)))
     (credential (unwrap! (contract-call? .credential-management get-credential (get credential-id request)) (err u404)))
     (responder tx-sender))
    (asserts! (is-eq responder (get institution credential)) (err u403))
    (map-set verification-requests
      { request-id: request-id }
      (merge request {
        status: (if is-verified "verified" "rejected"),
        response-date: (some block-height)
      })
    )
    (ok true)
  )
)

(define-read-only (get-verification-request (request-id uint))
  (map-get? verification-requests { request-id: request-id })
)

