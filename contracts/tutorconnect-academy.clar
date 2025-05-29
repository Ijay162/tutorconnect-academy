;; TutorConnect Academy: Decentralized tutoring platform with session booking and payments
;; Connects qualified tutors with students for personalized learning experiences

(define-data-var academic-director principal tx-sender)
(define-map tutor-profiles
  { tutor-id: uint }
  {
    educator: principal,
    hourly-rate: uint,
    subject-area: (string-ascii 50),
    qualifications: (string-ascii 500),
    experience-years: uint,
    accredited: bool
  }
)

(define-map session-history
  { tutor-id: uint, session-id: uint }
  {
    student: principal,
    booking-time: uint,
    session-type: (string-ascii 20)
  }
)

(define-data-var next-tutor-id uint u1)
(define-map session-tracker 
  { tutor-id: uint }
  { sessions: uint }
)

;; Register as a tutor
(define-public (register-tutor (subject-input (string-ascii 50)) (qualifications-input (string-ascii 500)) (years-input uint) (rate-input uint))
  (let
    (
      (tutor-id (var-get next-tutor-id))
      (session-id u0)
      (subject subject-input)
      (qualifications qualifications-input)
      (years years-input)
      (rate rate-input)
    )
    ;; Input validation
    (asserts! (> rate u0) (err u1))
    (asserts! (> (len subject) u0) (err u5))
    (asserts! (> (len qualifications) u0) (err u6))
    (asserts! (> years u0) (err u7))
    
    (map-set tutor-profiles
      { tutor-id: tutor-id }
      {
        educator: tx-sender,
        hourly-rate: rate,
        subject-area: subject,
        qualifications: qualifications,
        experience-years: years,
        accredited: false
      }
    )
    (map-set session-history
      { tutor-id: tutor-id, session-id: session-id }
      {
        student: tx-sender,
        booking-time: tutor-id,
        session-type: "registered"
      }
    )
    (map-set session-tracker 
      { tutor-id: tutor-id }
      { sessions: u1 }
    )
    (var-set next-tutor-id (+ tutor-id u1))
    (ok tutor-id)
  )
)

;; Book a tutoring session
(define-public (book-session (tutor-id-input uint))
  (let
    (
      (tutor-id tutor-id-input)
      (tutor-info (unwrap! (map-get? tutor-profiles { tutor-id: tutor-id }) (err u2)))
      (rate (get hourly-rate tutor-info))
      (educator (get educator tutor-info))
      (session-data (default-to { sessions: u0 } (map-get? session-tracker { tutor-id: tutor-id })))
      (session-id (get sessions session-data))
      (new-session-id (+ session-id u1))
    )
    ;; Input validation
    (asserts! (> tutor-id u0) (err u8))
    (asserts! (not (is-eq tx-sender educator)) (err u3))
    
    (try! (stx-transfer? rate tx-sender educator))
    (map-set session-history
      { tutor-id: tutor-id, session-id: session-id }
      {
        student: tx-sender,
        booking-time: (var-get next-tutor-id),
        session-type: "booked"
      }
    )
    (map-set session-tracker 
      { tutor-id: tutor-id }
      { sessions: new-session-id }
    )
    (ok true)
  )
)

;; Accredit a tutor (academic director only)
(define-public (accredit-tutor (tutor-id-input uint))
  (let
    (
      (tutor-id tutor-id-input)
      (tutor-info (unwrap! (map-get? tutor-profiles { tutor-id: tutor-id }) (err u2)))
      (session-data (default-to { sessions: u0 } (map-get? session-tracker { tutor-id: tutor-id })))
      (session-id (get sessions session-data))
      (new-session-id (+ session-id u1))
    )
    ;; Input validation
    (asserts! (> tutor-id u0) (err u8))
    (asserts! (is-eq tx-sender (var-get academic-director)) (err u4))
    
    (map-set tutor-profiles
      { tutor-id: tutor-id }
      (merge tutor-info { accredited: true })
    )
    (map-set session-history
      { tutor-id: tutor-id, session-id: session-id }
      {
        student: (get educator tutor-info),
        booking-time: (var-get next-tutor-id),
        session-type: "accredited"
      }
    )
    (map-set session-tracker 
      { tutor-id: tutor-id }
      { sessions: new-session-id }
    )
    (ok true)
  )
)

;; Get tutor profile
(define-read-only (get-tutor (tutor-id uint))
  (map-get? tutor-profiles { tutor-id: tutor-id })
)

;; Get session history entry
(define-read-only (get-session-record (tutor-id uint) (session-id uint))
  (map-get? session-history { tutor-id: tutor-id, session-id: session-id })
)

;; Get total sessions for a tutor
(define-read-only (get-session-count (tutor-id uint))
  (let
    (
      (session-data (default-to { sessions: u0 } (map-get? session-tracker { tutor-id: tutor-id })))
    )
    (get sessions session-data)
  )
)