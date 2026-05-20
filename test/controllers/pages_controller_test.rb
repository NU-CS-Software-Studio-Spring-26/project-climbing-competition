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
