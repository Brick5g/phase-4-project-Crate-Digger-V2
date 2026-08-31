# Crate Digger V2

Crate Digger V2 is a Ruby on Rails application for vinyl record collectors who want to organize their personal collections, discover records, and keep track of which artists, genres, and albums they own.

This version of Crate Digger expands on the original concept by using a relational Rails database, user authentication, nested resources, ActiveRecord associations, validations, scopes, and automated testing with RSpec and FactoryBot.

The goal of the application is to create a clean content management system for record collections while demonstrating a complete Rails MVC architecture.

## Features

- User signup, login, and logout
- Secure password authentication
- Create and manage a personal vinyl record collection
- Browse individual records and their details
- Associate records with artists and genres
- View all records belonging to a specific artist
- View all records belonging to a specific genre
- Add records directly to a user's collection through nested routes
- Prevent invalid or incomplete records from being saved
- Display validation errors directly in forms
- Filter records using ActiveRecord scopes
- Automated model and integration testing with RSpec
- FactoryBot-generated test data

## Domain Overview

The core models for Crate Digger V2 are:

### User

A User represents a collector using the application.

A user can own many records through collection entries.

Planned attributes:

- username
- email
- password_digest

### Record

A Record represents a vinyl release in the application.

Planned attributes:

- title
- release_year
- format
- condition

A record belongs to an artist and can belong to multiple genres.

### Artist

An Artist represents the musician or group responsible for a record.

Planned attributes:

- name
- country

An artist can have many records.

### Genre

A Genre represents a musical classification.

Planned attributes:

- name
- description

A genre can be associated with many records.

### CollectionEntry

CollectionEntry acts as a join model between User and Record.

Planned attributes:

- purchase_price
- notes

This model allows users and records to participate in a many-to-many relationship.

### RecordGenre

RecordGenre acts as a join model between Record and Genre.

Planned attributes:

- primary_genre
- notes

This model allows records and genres to participate in a many-to-many relationship.

