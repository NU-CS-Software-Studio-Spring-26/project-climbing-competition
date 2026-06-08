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

### Video storage on Heroku (Active Storage + Cloudinary)

Heroku dyno disk is ephemeral, so uploaded videos must be stored in cloud object storage.
This app is configured to use Cloudinary in production.

#### 1) Create / connect Cloudinary

Choose one of the two options:

- Option A (simplest on Heroku):
	1. Open your Heroku app dashboard.
	2. Go to the Resources tab.
	3. Search for the Cloudinary add-on and attach it.

- Option B (manual Cloudinary account):
	1. Create a Cloudinary account at cloudinary.com.
	2. From the Cloudinary dashboard, copy your CLOUDINARY_URL.

#### 2) Configure Heroku environment variables

Set these config vars on your Heroku app:

- ACTIVE_STORAGE_SERVICE=cloudinary
- CLOUDINARY_URL=<your cloudinary url>

If you used the Heroku add-on, CLOUDINARY_URL may be injected automatically, but verify it is present.

Commands:

- heroku config:set ACTIVE_STORAGE_SERVICE=cloudinary
- heroku config:set CLOUDINARY_URL="cloudinary://<api_key>:<api_secret>@<cloud_name>"

#### 3) Deploy code and migrate

From your repo:

1. bundle install
2. git add Gemfile Gemfile.lock config/storage.yml config/environments/production.rb README.md
3. git commit -m "Use Cloudinary for production Active Storage"
4. git push heroku <your-branch>:main
5. heroku run rails db:migrate

#### 4) Verify uploads in production

1. Open your Heroku app.
2. Submit a send with a video attachment.
3. Confirm no Active Storage errors in logs:
	- heroku logs --tail
4. In Cloudinary Media Library, verify the uploaded video appears.

#### 5) Troubleshooting checklist

- Error: "Missing CLOUDINARY_URL"
	- Run `heroku config` and confirm CLOUDINARY_URL is set.
- Upload succeeds locally but not on Heroku:
	- Confirm ACTIVE_STORAGE_SERVICE=cloudinary on Heroku.
	- Redeploy after setting config vars.
- Large upload issues:
	- Check Heroku router/app timeouts and Cloudinary plan upload limits.
	- Prefer short video clips and compressed formats (mp4/h264) for submissions.

## Description: 
A service for virtual climbing competitions, particularly bouldering.

Climbing competitions are usually an in-person activity, done in local gyms or outdoor routes. However, there are universal training boards in most gyms. These boards, such as Kilter Board and Tension Board, have customizable angles and can be used to set various routes using individual lighting on holds. And they’re all standardized, so a Kilter board in my gym has the same layout as a Kilter anywhere else.

The service will allow competition hosts to set special routes on the board and invite competitors. Competitors will have a time period to film their attempts on the routes and submit them. Submissions can be validated using manual review or even AI assessment.

## Communication:
Meeting scheduling is done via when2meet, with reoccuring meetings happeing every Sunday in Mudd Library. Communication will be done via Slack and Zoom meetings. Decision-making is done by vote if it has major implications for direction of project, otherwise will be up to personal discretion to increase efficiency. 

