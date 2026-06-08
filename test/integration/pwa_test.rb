require "test_helper"

class PwaTest < ActionDispatch::IntegrationTest
  test "manifest is available" do
    get pwa_manifest_path(format: :json)

    assert_response :success
    assert_match "board base", response.body
    assert_match '"display": "standalone"', response.body
  end

  test "service worker is available" do
    get pwa_service_worker_path, as: :js

    assert_response :success
    assert_equal "text/javascript", response.media_type
    assert_match "service worker", response.body.downcase
  end

  test "home page links manifest without changing normal layout" do
    get root_url

    assert_response :success
    assert_select "link[rel='manifest'][href=?]", pwa_manifest_path(format: :json)
    assert_select "link[rel='icon'][href='/icon.svg']"
  end
end
