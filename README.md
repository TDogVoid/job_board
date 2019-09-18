# JobBoard


## unmaintained

This project is not maintained.

This is a little side business I created but ultimatly shutdown as I just couldn't get any traction.  This was also my first phoenix project so there are definetly some mistakes and weired decisions I made.  I was also slowly seperating out the name of the website as I was thinking about using the code on other websites.


Required Role Named "User" this is the default role

Required Environment variables
image
  * SECRET_KEY_BASE
  * DATABASE_URL
  * PORT
  * SECRET_ACCOUNT_VERIFICATION_SALT
  * MAILGUN_API_KEY
  * MAILGUN_DOMAIN_KEY (ie. mail.example.com)
  * RECAPTCHA_PUBLIC_KEY
  * RECAPTCHA_PRIVATE_KEY
  * MAILCHIMP_API_KEY
  * STRIPE_SECRET_KEY
  * STRIPE_PUBLIC_KEY


for system dokku
  * export POSTGRES_IMAGE="mdillon/postgis"
  * export POSTGRES_IMAGE_VERSION="latest"


To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.create && mix ecto.migrate`
  * Install Node.js dependencies with `cd assets && npm install`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](http://www.phoenixframework.org/docs/deployment).

## Learn more

  * Official website: http://www.phoenixframework.org/
  * Guides: http://phoenixframework.org/docs/overview
  * Docs: https://hexdocs.pm/phoenix
  * Mailing list: http://groups.google.com/group/phoenix-talk
  * Source: https://github.com/phoenixframework/phoenix
