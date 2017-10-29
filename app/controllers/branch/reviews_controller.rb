class Branch::ReviewsController < Branch::BaseController
  before_action :authorize_create_review, only: [:create, :update]

  def index
    @q = displayable_reviews.ransack params[:q]
    @q.sorts = default_sorting_option if @q.sorts.empty?
    @reviews = @q.result.includes(:user).decorate
  end

  def new
    @create_review_form = CreateReviewForm.new
  end

  def create
    @create_review_form = CreateReviewForm.new review_params.merge user: current_user,
      branch: branch
    if @create_review_form.save
      flash[:success] = t ".success"
      redirect_to branch_reviews_path @branch
    else
      flash.now[:failed] = t ".failed"
      render :new
    end
  end

  private
  def authorize_create_review
    raise Pundit::NotAuthorizedError unless policy(@branch).can_review?
  end

  def review_params
    params.require(:create_review_form).permit CreateReviewForm::PARAMS
  end

  def displayable_reviews
    if user_signed_in?
      @branch.reviews.verified.with_voted_type_by_user(current_user)
    else
      @branch.reviews.verified
    end
  end

  def default_sorting_option
    Review::SORTING_OPTIONS.first[:value]
  end
end
