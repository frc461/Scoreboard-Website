# The big idea
Scoreboard that has each of our team's matches
* RP
* Next match with all of the teams in it

# Getting started
* Install ruby and bundler
* Run `run.bat`

# Git stuffs
## Cloning
* `git clone [repo location]`
## Commiting
* `git add.`
* `git commit -m "[message]"`
* `git push`
## Pulling
* `git stash` -- This saves your current progress before you pull new code
* `git pull`
* `git stash pop`
* **You may need to go through merges!**

# Structure
## Base folder
* App (driver code)
* Gemfile (all of the libraries needed to run `app.rb`)
## Public
* Stores all of javascript and images
## Views
* This is where all of the code for the webpages needs to be
* Any javascript that is written must be put in a seperate folder (likely `/javascript`) from the root folder
* `application.erb` will have all of the formatting that is the same throughout each webpage -- if you're repeating code throughout all of the pages, just put it once in here
## Lib
* All of the external javascript is located here
## Bug
* This is a git repo to make the webpage more interactive