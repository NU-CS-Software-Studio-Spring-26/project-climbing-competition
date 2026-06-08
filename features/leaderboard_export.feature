@leaderboard_export
Feature: Leaderboard CSV export
  As a competition host
  I want to export leaderboard statistics as CSV
  So I can analyze results outside the app

  Background:
    Given a competition host exists for leaderboard export
    And an active competition with enrolled competitors exists

  Scenario: Host exports leaderboard statistics as CSV
    Given competitors have logged attempts on the competition
    And the host is signed in for leaderboard export
    When the host downloads the leaderboard CSV
    Then the CSV should include competitor rankings and per-climb stats

  Scenario: Host sees the export link on the competition page
    Given the host is signed in for leaderboard export
    When the host visits the competition page for leaderboard export
    Then the host should see the export leaderboard link

  Scenario: A non-owner cannot export the leaderboard CSV
    Given competitors have logged attempts on the competition
    And a non-owner is signed in for leaderboard export
    When the non-owner requests the leaderboard CSV
    Then the export should be forbidden

  Scenario: A guest must sign in before exporting
    When a guest requests the leaderboard CSV
    Then the guest should be redirected to sign in
