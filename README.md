# Slotty

Online booking for independent service providers: barbers, manicurists, tutors.

A master signs up, lists their services and weekly working hours, and shares one link
(`/book/<slug>`). Clients open it, pick a service and a free time slot, and book
without creating an account.

## Features

- Sign up / sign in (Rails 8 built-in authentication)
- Services: name, duration, price; can be deactivated instead of deleted when they have bookings
- Weekly schedule: several working intervals per day, overlapping intervals are rejected
- Public booking page: free slots for the next 14 days, booking form for the client
- Double booking is impossible, including two clients submitting at the same moment
- Master's list of upcoming bookings with cancellation
- Confirmation email to the client, sent in the background

## Stack

- Ruby 4.0, Rails 8.1
- PostgreSQL
- Hotwire (Turbo), Tailwind CSS
- Active Job (Solid Queue in production), Action Mailer
- RSpec, FactoryBot, shoulda-matchers

## Technical decisions

### Preventing double booking

Two clients can see the same free slot and submit the form at the same moment. Both requests
check the slot, both see it as free, and both insert a booking: a check in Rails cannot close
the gap between "check" and "insert". So the database enforces the rule itself with an
exclusion constraint: confirmed bookings of the same master cannot overlap in time
(touching is allowed). The controller catches the violation and shows "this time is no longer
available" instead of an error page.

The check in Rails (`slot_available?`) is still needed: the constraint only knows about
overlaps between bookings. It knows nothing about working hours or the slot grid, so it would
accept a booking at 10:05 or at 3 a.m. as long as nothing else is booked then.

### Calculating free slots

`AvailableSlots` takes a service and a date and returns the start times a client can book:
the master's working hours for that weekday minus the time taken by their bookings.
Rules: a 15-minute grid; the service must fit completely before the end of a working interval;
bookings of all the master's services count, cancelled ones don't; a slot may start right
when another booking ends; slots in the past are not offered.

It is a plain Ruby class rather than a model or controller method because two places use it
(the slots page and the final check when booking), and because it is easy to test in
isolation: the current time is passed in, so tests don't depend on the clock.

### Confirmation email

The email is sent with `deliver_later`: it goes to a background job queue instead of being
sent during the request. Sending can be slow or fail; the client shouldn't wait for it,
and a failed job can be retried.

It is sent from the controller, not from an `after_create_commit` callback on `Booking`.
A callback would fire on every booking created anywhere (tests, seeds, a future "add booking"
form for the master), while the email belongs to one scenario: a client booking on the
public page. The trade-off is that a new booking scenario has to send the email explicitly.

## Running locally

Requirements: Ruby 4.0.1, PostgreSQL.

```sh
bin/setup        # installs gems, creates and migrates the database, starts the server
bin/dev          # starts the server and the Tailwind watcher on http://localhost:3000
```

Sign up, add a service and working hours, then open "Public page" on the dashboard
to book as a client. In development emails are not sent; they are written to `tmp/mails/`.
Email previews: http://localhost:3000/rails/mailers

## Tests

```sh
bin/rspec
bin/rubocop
```
