# Crate Digger V2 — User Stories

## Overview

Crate Digger V2 is a Ruby on Rails application that allows vinyl record collectors to create an account, manage a personal record collection, and explore records through their artists and genres.

These user stories define the planned functionality of the application and will guide development throughout the project.

---

## Authentication

### User Story 1 — Sign Up

As a new visitor,  
I want to create an account,  
so that I can build and manage my own record collection.

### Acceptance Criteria

- A visitor can access a signup form.
- A visitor can enter a username, email, password, and password confirmation.
- A valid signup creates a new user.
- Passwords are securely stored using `has_secure_password`.
- Invalid information does not create a user.
- Validation errors are displayed on the signup form.

---

### User Story 2 — Log In

As a registered user,  
I want to log in to my account,  
so that I can access and manage my personal collection.

### Acceptance Criteria

- A registered user can access a login form.
- A user can log in using valid credentials.
- Invalid credentials do not create a session.
- After logging in, the application recognizes the current user.

---

### User Story 3 — Log Out

As a logged-in user,  
I want to log out of my account,  
so that my account is no longer accessible from the current session.

### Acceptance Criteria

- A logged-in user can log out.
- Logging out clears the user's session.
- The user is redirected appropriately after logging out.

---

## Record Collection

### User Story 4 — View My Collection

As a logged-in collector,  
I want to view the records in my collection,  
so that I can see what I currently own.

### Acceptance Criteria

- A user can view their collection.
- Each collection entry displays information about its associated record.
- Records belonging to other users are not presented as part of the current user's collection.
- An empty collection displays an appropriate message.

---

### User Story 5 — Add a Record to My Collection

As a logged-in collector,  
I want to add a record to my collection,  
so that I can keep track of the records I own.

### Acceptance Criteria

- A collection entry is created in the context of a user.
- The application uses a nested RESTful route for this relationship.
- A user can select or associate a record with the collection entry.
- A user can provide collection-specific information such as purchase price and notes.
- Invalid collection entries are not saved.
- Validation errors are displayed in the form.

### Planned Nested Routes

```text
/users/:user_id/collection_entries
/users/:user_id/collection_entries/new
/users/:user_id/collection_entries/:id
```

---

### User Story 6 — View a Collection Entry

As a logged-in collector,  
I want to view information about an individual item in my collection,  
so that I can see its record and collection-specific details.

### Acceptance Criteria

- A user can navigate to an individual collection entry.
- The page displays information about the associated record.
- The page displays collection-specific information such as notes and purchase price.

---

### User Story 7 — Edit a Collection Entry

As a logged-in collector,  
I want to update information about a record in my collection,  
so that my collection remains accurate.

### Acceptance Criteria

- A user can access an edit form for their collection entry.
- Existing information appears in the form.
- Valid changes update the collection entry.
- Invalid changes are not saved.
- Validation errors are displayed to the user.

---

### User Story 8 — Remove a Record From My Collection

As a logged-in collector,  
I want to remove a record from my collection,  
so that my collection reflects the records I currently own.

### Acceptance Criteria

- A user can remove one of their collection entries.
- Removing the collection entry does not necessarily delete the canonical record from the database.
- The user is redirected back to an appropriate collection page after deletion.

---

## Records

### User Story 9 — Browse Records

As a visitor,  
I want to browse records stored in Crate Digger,  
so that I can discover music and see what records are available in the application.

### Acceptance Criteria

- A visitor can view an index of records.
- Each record displays useful identifying information.
- A visitor can navigate from the record index to an individual record.

---

### User Story 10 — View a Record

As a visitor,  
I want to view an individual record,  
so that I can learn more about the release.

### Acceptance Criteria

- A record page displays its title.
- A record page displays its release year.
- A record page displays its format and condition.
- A record page displays its artist.
- A record page displays its associated genres.

---

### User Story 11 — Create a Record

As a logged-in user,  
I want to add a record to Crate Digger,  
so that records not already represented in the application can be cataloged.

### Acceptance Criteria

- A logged-in user can access a new record form.
- A record requires valid information before being saved.
- A record can be associated with an artist.
- A record can be associated with one or more genres.
- Validation errors are displayed when the record cannot be saved.

---

### User Story 12 — Edit a Record

As a logged-in user,  
I want to edit a record,  
so that incorrect or incomplete record information can be updated.

### Acceptance Criteria

- A user can access an edit form for a record.
- Existing record information appears in the form.
- Valid changes update the record.
- Invalid changes do not update the record.
- Validation errors are displayed.

---

## Artists

### User Story 13 — Browse Artists

As a visitor,  
I want to browse artists,  
so that I can discover records through the musicians who created them.

### Acceptance Criteria

- A visitor can view an index of artists.
- Each artist displays identifying information.
- A visitor can navigate to an individual artist.

---

### User Story 14 — View an Artist's Records

As a visitor,  
I want to view all records associated with an artist,  
so that I can explore that artist's releases.

### Acceptance Criteria

- An artist page displays the artist's name.
- An artist page displays the artist's country when available.
- The page displays records belonging to the artist.
- A visitor can navigate from an artist to an individual record.

---

## Genres

### User Story 15 — Browse Genres

As a visitor,  
I want to browse music genres,  
so that I can discover records based on the type of music I am interested in.

### Acceptance Criteria

- A visitor can view an index of genres.
- Genre names are displayed.
- A visitor can navigate to an individual genre.

---

### User Story 16 — View Records by Genre

As a visitor,  
I want to view records associated with a particular genre,  
so that I can discover music within that genre.

### Acceptance Criteria

- A genre page displays the genre's name.
- A genre page can display its description.
- The page displays records associated with the genre.
- Records and genres are connected through `RecordGenre`.

---

## Record Filtering

### User Story 17 — Filter Records

As a collector,  
I want to filter records using useful categories,  
so that I can more easily find records that interest me.

### Acceptance Criteria

- At least one filter is powered by an ActiveRecord scope.
- The filtering logic exists at the model level rather than being duplicated in the controller.
- The filtered results display only records matching the selected criteria.

### Planned Scope Example

```ruby
scope :recent_releases, -> { where("release_year >= ?", 2000) }
```

Additional filters may later include:

- Release year
- Record format
- Record condition
- Genre

---

# Planned Domain Relationships

## User

```ruby
has_many :collection_entries
has_many :records, through: :collection_entries
```

A user owns many records through their collection entries.

---

## CollectionEntry

```ruby
belongs_to :user
belongs_to :record
```

`CollectionEntry` acts as the join model between `User` and `Record`.

---

## Record

```ruby
belongs_to :artist

has_many :collection_entries
has_many :users, through: :collection_entries

has_many :record_genres
has_many :genres, through: :record_genres
```

A record belongs to an artist and can appear in many users' collections.

A record can also belong to multiple genres through `RecordGenre`.

---

## Artist

```ruby
has_many :records
```

An artist can have many records.

---

## Genre

```ruby
has_many :record_genres
has_many :records, through: :record_genres
```

A genre can contain many records through `RecordGenre`.

---

## RecordGenre

```ruby
belongs_to :record
belongs_to :genre
```

`RecordGenre` acts as the join model between `Record` and `Genre`.

---

# Rails Requirement Coverage

The planned Crate Digger V2 domain supports the project requirements through the following features:

| Requirement | Crate Digger V2 Implementation |
| --- | --- |
| Ruby on Rails | Application built using Rails |
| `has_many` | Artist has many records, User has many collection entries |
| `belongs_to` | Record belongs to Artist; join models belong to their associated models |
| `has_many :through` | User → Records through CollectionEntries |
| Second `has_many :through` | Record ↔ Genres through RecordGenres |
| Join model | CollectionEntry and RecordGenre |
| Model validations | Users, Records, Artists, Genres, CollectionEntries, and RecordGenres |
| ActiveRecord scope | Record filtering such as `recent_releases` |
| Authentication | Signup, login, logout, `bcrypt`, and `has_secure_password` |
| Nested resource | User → CollectionEntries |
| Nested form | Add a CollectionEntry in the context of a User |
| Validation errors | Forms display model validation errors |
| Model testing | RSpec model specs |
| Integration testing | Request or feature specs |
| FactoryBot | Factories used to generate test data |
| DRY application | Model methods, helpers, partials, and RESTful controllers |
| RuboCop | Project checked against required Ruby linting conventions |
| README | Project description and installation instructions included |
| No scaffolding | Models, controllers, routes, and views built manually |

---

# Development Priorities

Development will proceed incrementally so that each feature can be tested before moving to the next.

1. Build and test the core models and database relationships.
2. Implement user authentication.
3. Implement record browsing and management.
4. Implement the user's nested collection resources.
5. Implement artists and genres.
6. Add record filtering through ActiveRecord scopes.
7. Add validation error handling to forms.
8. Add integration testing.
9. Refactor repeated code using helpers and partials.
10. Run the complete RSpec and RuboCop suites before final submission.

---

# Definition of Done

Crate Digger V2 will be considered functionally complete when a user can:

- Create an account.
- Log in and log out.
- Browse records.
- View artists and their records.
- View genres and their records.
- Add records to their personal collection.
- Edit and remove collection entries.
- Create and update record information.
- Filter records using an ActiveRecord scope.
- Receive useful validation messages when submitting invalid forms.

The application should also have passing RSpec tests and return no RuboCop offenses.