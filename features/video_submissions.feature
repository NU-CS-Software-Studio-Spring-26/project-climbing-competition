@video_submissions
Feature: Video submission and host validation
  As a competition host
  I want competitors to submit send videos when required
  So I can validate climbs and adjust points if needed

  Background:
    Given a competition host exists
    And a competition with at least two climbs exists

  Scenario: Competitor gets points immediately when submitting a completed send with video
    Given video submissions are required for the competition
    And a competitor is enrolled in the competition
    When the competitor submits a completed send with an attached video
    Then the competitor should see a successful save message
    And the competitor should receive points immediately

  Scenario: Host invalidates a previously scored send after reviewing video
    Given a competitor has a scored completed send with an uploaded video
    When the host marks that submission as invalid
    Then the competitor's points for that climb should become 0
    And the leaderboard should reflect the updated score
