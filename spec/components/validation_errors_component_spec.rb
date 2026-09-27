# frozen_string_literal: true

require "rails_helper"

RSpec.describe ValidationErrorsComponent, type: :component do
  it "renders validation errors" do
    user = User.new

    user.valid?

    render_inline(
      described_class.new(
        resource: user
      )
    )

    expect(page).to have_css(
      ".validation-errors"
    )

    expect(page).to have_content(
      "Email can't be blank"
    )

    expect(page).to have_content(
      "Username can't be blank"
    )
  end

  it "renders nothing when there are no errors" do
    user = build(
      :user
    )

    render_inline(
      described_class.new(
        resource: user
      )
    )

    expect(page).not_to have_css(
      ".validation-errors"
    )
  end
end
