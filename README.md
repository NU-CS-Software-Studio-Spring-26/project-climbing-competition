# Virtual-Climbing-Competition
CS-397 Climbing Project 

**Developers:** Eric Wang, Ethan Pan, Ishani Pidara, Hannah Kwak

### MVP: 
A platform to create climbing leagues with designated competition climbs on the Kilterboard with leaderboard feature. 
See Heroku deployment here: https://climb-league-c5d605affe21.herokuapp.com/

### Local development seeds

- `bin/rails db:seed` — small dataset for everyday dev and CI
- `bin/rails db:seed:large` — development only; ~1000 users and competitions for UI stress-testing

### Google sign-in setup

1. Create OAuth credentials in Google Cloud Console and add callback URL:
	- `http://localhost:3000/auth/google_oauth2/callback`
2. Set environment variables before running the server:
	- `GOOGLE_CLIENT_ID`
	- `GOOGLE_CLIENT_SECRET`
3. Run migrations:
	- `bin/rails db:migrate`
4. Start the app and use "Continue with Google" on the sign-in page.

## Description: 
A service for virtual climbing competitions, particularly bouldering.

Climbing competitions are usually an in-person activity, done in local gyms or outdoor routes. However, there are universal training boards in most gyms. These boards, such as Kilter Board and Tension Board, have customizable angles and can be used to set various routes using individual lighting on holds. And they’re all standardized, so a Kilter board in my gym has the same layout as a Kilter anywhere else.

The service will allow competition hosts to set special routes on the board and invite competitors. Competitors will have a time period to film their attempts on the routes and submit them. Submissions can be validated using manual review or even AI assessment.

## Communication:
Meeting scheduling is done via when2meet, with reoccuring meetings happeing every Sunday in Mudd Library. Communication will be done via Slack and Zoom meetings. Decision-making is done by vote if it has major implications for direction of project, otherwise will be up to personal discretion to increase efficiency. 

