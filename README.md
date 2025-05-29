# TutorConnect Academy

A decentralized tutoring platform built on the Stacks blockchain that connects qualified educators with students seeking personalized learning experiences.

## Overview

TutorConnect Academy revolutionizes online education by enabling direct connections between tutors and students, with transparent session booking, payment processing, and academic accreditation through blockchain technology.

## Features

- Register as a tutor with subject expertise and hourly rate settings
- Book tutoring sessions using STX tokens with direct educator payments
- Track complete session history and student-tutor interactions
- Academic director accreditation system for tutor quality assurance
- Immutable record of all tutoring activities and qualifications

## Smart Contract Functions

### Public Functions

- `register-tutor`: Educators can register with qualifications, subjects, and hourly rates
- `book-session`: Students can book tutoring sessions by paying educators
- `accredit-tutor`: Academic director can accredit qualified tutors

### Read-Only Functions

- `get-tutor`: Retrieve complete tutor profile and qualification details
- `get-session-record`: View specific tutoring session records
- `get-session-count`: Check total number of sessions for a tutor

## Development

Built using Clarity smart contracts on the Stacks blockchain for transparent educational services.

### Prerequisites

- [Clarinet](https://github.com/hirosystems/clarinet)
- [Stacks CLI](https://github.com/blockstack/stacks.js)

### Testing

Run tests using Clarinet:

```bash
clarinet test