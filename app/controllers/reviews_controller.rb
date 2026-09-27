class ReviewsController < ApplicationController
  before_action :require_login

  before_action :set_record,
                only: [ :new, :create ]

  before_action :set_review,
                only: [ :edit, :update, :destroy ]

  def new
    @review =
      current_user.reviews.new(
        record: @record
      )
  end

  def create
    @review =
      current_user.reviews.new(
        review_params
      )

    @review.record =
      @record

    if @review.save
      redirect_to record_path(
        @record
      )
    else
      render :new,
             status: :unprocessable_content
    end
  end

  def edit
  end

  def update
    if @review.update(
      review_params
    )
      redirect_to record_path(
        @review.record
      )
    else
      render :edit,
             status: :unprocessable_content
    end
  end

  def destroy
    record =
      @review.record

    @review.destroy

    redirect_to record_path(
      record
    )
  end

  private

  def set_record
    @record = Record.find(
      params[:record_id]
    )
  end

  def set_review
    @review =
      current_user.reviews.find(
        params[:id]
      )
  end

  def review_params
    params.require(
      :review
    ).permit(
      :rating,
      :body
    )
  end
end
