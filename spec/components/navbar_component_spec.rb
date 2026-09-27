# frozen_string_literal: true

require "rails_helper"

RSpec.describe NavbarComponent, type: :component do
  it "shows guest navigation when logged out" do
    render_inline(
      described_class.new(
        current_user: nil
      )
    )

    expect(page).to have_link(
      "Crate Digger"
    )

    expect(page).to have_link(
      "Sign Up"
    )

    expect(page).to have_link(
      "Log In"
    )

    expect(page).not_to have_link(
      "My Collection"
    )
  end

  it "shows user navigation when logged in" do
    user = create(
      :user
    )

    render_inline(
      described_class.new(
        current_user: user
      )
    )

    expect(page).to have_link(
      "Find Music"
    )

    expect(page).to have_link(
      "My Collection"
    )

    expect(page).to have_button(
      "Log Out"
    )

    expect(page).not_to have_link(
      "Sign Up"
    )
  end
end
