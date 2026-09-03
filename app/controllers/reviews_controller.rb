class ReviewsController < ApplicationController
  before_action :require_login

  def new
    @record = Record.find(params[:record_id])
    @review = current_user.reviews.new(record: @record)
  end

  def create
    @record = Record.find(params[:record_id])

    @review = current_user.reviews.new(
      review_params
    )

    @review.record = @record

    if @review.save
      redirect_to record_path(@record)
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
    @review = current_user.reviews.find(params[:id])
  end

  def update
    @review = current_user.reviews.find(params[:id])

    if @review.update(review_params)
      redirect_to record_path(@review.record)
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @review = current_user.reviews.find(params[:id])
    record = @review.record

    @review.destroy

    redirect_to record_path(record)
  end

  private

  def review_params
    params.require(:review).permit(
      :rating,
      :body
    )
  end
end
