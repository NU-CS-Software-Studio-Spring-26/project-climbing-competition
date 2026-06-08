require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "should get about" do
    get about_url
    assert_response :success
    assert_select "h1", text: /about us/i
    assert_select "a.about-github-link", text: "View on GitHub"
  end

  test "should get terms" do
    get terms_url
    assert_response :success
    assert_select "h1", text: /terms of service/i
    assert_select "a[href=?]", "mailto:ethanpan2028@u.northwestern.edu"
  end

  test "should get privacy" do
    get privacy_url
    assert_response :success
    assert_select "h1", text: /privacy policy/i
  end

  test "should get tutorial" do
    get tutorial_url
    assert_response :success
    assert_select "nav.app-nav--top a.app-nav-link", text: "tutorial"
    assert_select "h1", text: /how to use board base/i
    assert_select "h2", text: /join a competition/i
    assert_select "h2", text: /create a competition/i
    assert_select "h2", text: /what to do after you join/i
    assert_select ".tutorial-preview--cards .competition-card"
    assert_select ".tutorial-preview--show .climb-card-link"
    assert_select "figcaption", text: /JOIN/
  end

  test "footer appears on home and legal pages" do
    get root_url
    assert_response :success
    assert_select "footer.app-footer"
    assert_select "a.app-footer-link", text: "About"
    assert_select "a.app-footer-link", text: "Terms of Service"
    assert_select "a.app-footer-link", text: "GitHub"
    assert_select "span.app-footer-tagline"
  end
end
