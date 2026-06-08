@forgot_password
Feature: Forgot password
  As a climber with a password account
  I want to request a password reset safely
  So I can regain access without exposing account existence

  Scenario: Requesting a reset from sign in succeeds with a generic message
    Given a password user exists for forgot password
    When I request a password reset for that user from the sign in page
    Then I should see the generic password reset confirmation

  Scenario: Unknown email still shows the same generic confirmation
    Given I am on the forgot password page
    When I submit a forgot password request for an unknown email
    Then I should see the generic password reset confirmation
