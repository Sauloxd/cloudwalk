# CLoudwalk challenge

## Deliverables
- Part 1 [here](./part-1.md)
- Part 2 [here](./part-2.md)
- Part 3 is the codebase itself

## About this project

This web application consists of a single endpoint: `/frauds/check` which receives a transaction and determines if the transaction is a fraud or not.

## Requirements

All dependencies are inside the dockerfile inside .devcontainer
Use VSCode, press  F1 > Dev Container: Rebuild Container and VSCode will start the container running the project and Redis.
Open integrated terminal in Vscode, run `bundle install` and start hanami by running: `hanami server` 
If it does not work, run `docker compose up` in `.devcontainer/` folder.

This application requires Ruby 3.2.2 and Redis running on port 6379

### Architecture

I decided to use Hanami as the webserver framework due to its simplicity, but on hindsight it might not have been a good idea since it's the first time I worked with it.
I organized the code as I would a regular Rails application, but following some of Hanami practices, for example: instead of "controllers", we have the "actions" folder, but they have the same purpose

The overall flow is:
1. Endpoint is called
2. Ratelimit middleware is called and control overusage of this application
3. Request is allowed to be executed by the Frauds::Check action
4. The [action](app/actions/frauds/check.rb) parses the payload, and creates an instance of [Transaction](app/models/transaction.rb) model
5. When the model tries to save itself, it first validates if this is a valid transaction
6. The validation is performed by the [::Frauds::Check::Policy](app/policies/frauds/check/policy.rb) class
7. Which call each individual validation against this transaction
8. After all validations are called, the model decides if it should persist this transaction (as it will only persist valid transactions). Very similar to how ActiveRecord works
9. Reasons are also rendered to the caller of this endpoint.

#### Why there is a rate limit here?

The requirement `Reject transaction if user is trying too many transactions in a row` was not so clear to me, at it really felt like a description of a rate limit.
Just in case I implemented a very simple/naive ratelimit that probably won't work at scale (as syncing the tokens for distributed system is not so trivial)
It uses the simple [bucket token algorithm](https://jgam.medium.com/rate-limiter-token-bucket-algorithm-efd86758c8ee).
I tried to implement a transaction in Redis by leveraging the LUA scripts and the watch/unwatch features.
The idea is that, to avoid reading and updating in separated commands, I perform both at the same time, thus avoiding race conditions.

#### Why the main database is Redis?

Honestly it was due the fact the rate limit was using one already. Probably on a really large dataset, I would use a noSQL, since a fraud system requires more speed over super consistency, like an actual banking system.
Since the dataset provided is 260kb only, I could have skipped using Redis and used just an in-memory object, but for the sake of the challenge I decided to use Redis, as there are advantages on using Redis for perfomance.