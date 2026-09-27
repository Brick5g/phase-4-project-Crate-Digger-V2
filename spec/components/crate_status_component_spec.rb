# frozen_string_literal: true

require "rails_helper"

RSpec.describe CrateStatusComponent, type: :component do
  let(:record) do
    create(
      :record
    )
  end

  it "asks a guest to log in" do
    render_inline(
      described_class.new(
        record: record,
        current_user: nil
      )
    )

    expect(page).to have_content(
      "Log in to save this release"
    )

    expect(page).to have_link(
      "Log In"
    )
  end

  it "allows a logged in user to save an unsaved release" do
    user = create(
      :user
    )

    render_inline(
      described_class.new(
        record: record,
        current_user: user
      )
    )

    expect(page).to have_content(
      "Not Saved Yet"
    )

    expect(page).to have_link(
      "Save to My Collection"
    )
  end

  it "shows when the release is already saved" do
    user = create(
      :user
    )

    create(
      :collection_entry,
      user: user,
      record: record
    )

    render_inline(
      described_class.new(
        record: record,
        current_user: user
      )
    )

    expect(page).to have_content(
      "Saved to My Collection"
    )

    expect(page).to have_link(
      "View My Collection"
    )

    expect(page).not_to have_link(
      "Save to My Collection"
    )
  end
end
