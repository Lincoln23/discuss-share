# Discuss & Share

This app will allow people with similar interests to follow each other, live chat, and stay up to date with each other through their posts!
 
## Setup
 Requires: 
 - Ruby 2.5.3 
 - Rails 5.2.2 
 - MySQL
 - ElasticSearch version >= 6.4
 
 Clone this repo
 - Update `config/database.yml with your database settings`
 - run `bundle install`
 - run `rails db:migrate`
 - `rails db:seed` if you want a sample dataset 
 - start server by `rails s`
 - start ElasticSearch server 
 
## Features

### Signing up 
You will need to create a username and password along with your email address to sign up 
  - Your email address is used to activate your account and reset your password if forgotten
  - When logging in, if “remember me” is checked, you will not have to re-login even after closing your browser
  - The profile picture associated with your email address is fetched on Gravatar
### Share posts 
Share thoughts and updates with your followers by writing posts
  - Now supports file uploads so you can upload images and attachments 

Follow other users and stay up to date with their posts in your feed 
  - **Note**: If you follow a certain user, they will not automatically follow you back 
  
### Searching 
Want to find a post but can’t remember who wrote it? Want to find a post but you can only remember parts of it?
  - Go to the search page and type in what you remember! 
    -  If you remember who wrote it, type in their user_name or email address
    - If you remember only parts of a post, type that in and it will return auto-complete suggestions or posts that have partial matches 
     


### Live chat 
Discussion in real time! Use the live chat feature to talk to other about topics you care about!
  - You can ping other users in chat by typing @[their name]
  
## Technical Details 

### Autocomplete suggestion and fuzzy matching

  - Using ElasticSearch, I have created search functionality that will predict what you are typing and match documents even though it is not a 100% match 
    -  To do this, I first apply a standard tokenizer on the input to separate the text into words. I then apply lowercase, asciifolding and Ngram filters to create lowercase N-grams of words to be indexed and searched
    - I index the contents of the posts, username and email addresses to allow users to find posts created by a certain user or search for posts

### Live chat 
   - Real-time multi-way communication for users to chat with each other was built using `ActionCable` (Websockets)
   - All users are subscribed to a general channel. Messages submitted by any user in the chat are broadcasted
   - `@mention feature`: Users are subscribed to their own private channel using their unique `user_id`.
      - When any message is submitted, it is parsed for `@Name` using regex and if it matches a user, an alert to broadcasted to their channel 
### Login system
  - Implemented using `bycrpyt` to keep user password safe in the database by storing the hashed version of the password
  - User session is persisted across pages using Rails `session`
  - `Remember me` feature is implemented by generating a unique hash then encrypting and storing it on the browser’s cookies and database.
    - When a user visits this application after closing their browser, the app authenticates by decrypting the stored browser cookie with the database and checks if the current user is valid 
    - When a user logs out of their account, the stored hash is deleted both in the browser and database. Doing so will prevent someone from having permanent access to a user's account if the database is compromised 
   
### Mailer
#### Account activation and password resets 
 - Users are required to activate their account by going to their email address and confirming
  -  Mailers are sent using `Action Mailer`
  - A unique hash is generated when the user first creates an account and a unique link with the hash as a query parameter is sent to the account's email address.
    - When the user clicks the "activate my account" button, the hash is authenticated with the one stored in the database 
  - This works the same for password resets 
  
### Database
 - Using `MYSQL` database
 - Modelled following users using a `many to many` relationship and a join table
 
 
 
  
