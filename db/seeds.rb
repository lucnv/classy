puts "Creating admin account"
User.create! email: "admin@gmail.com",
  first_name: Faker::Name.first_name,
  last_name: Faker::Name.last_name,
  role: :admin,
  password: "123456",
  password_confirmation: "123456",
  confirmed_at: Time.zone.now,
  avatar: Faker::Avatar.image

puts "Creating moderator account"
User.create! email: "moderator@gmail.com",
  first_name: Faker::Name.first_name,
  last_name: Faker::Name.last_name,
  role: :moderator,
  password: "123456",
  password_confirmation: "123456",
  confirmed_at: Time.zone.now,
  avatar: Faker::Avatar.image

puts "Creating normal users"
10.times.each do |i|
  User.create! email: "member#{i}@gmail.com",
    first_name: Faker::Name.first_name,
    last_name: Faker::Name.last_name,
    role: :normal_user,
    password: "123456",
    password_confirmation: "123456",
    confirmed_at: Time.zone.now,
    avatar: Faker::Avatar.image
end

training_types = TrainingType.all.includes :categories
districts = District.all.includes :city
puts "Creating training center"
20.times.each do
  training_type = training_types.sample
  center = Center.create! name: Faker::Educator.university,
    training_type: training_type,
    status: :active,
    description: Faker::Lorem.paragraphs.join("\n")

  category_count = rand(3) + 1
  training_type.categories.sample(category_count).each do |category|
    center.center_categories.create! category: category
  end
end


puts "Create branches"
Center.find_each do |center|
  branches_count = rand(10) + 1
  branches_count.times.each do |i|
    district = districts.sample
    location = ["(21.063590, 105.842285)", "(21.080895, 105.749686)", "(21.026275, 105.812005)", "(20.986202, 105.839836)", "(21.108168, 105.814410)",
      "(20.969633, 105.863441)", "(20.993302, 105.880452)", "(20.962160, 105.798326)", "(20.949449, 105.776151)", "(20.998405, 105.958812)", "(21.081203, 105.920982)"
    ]
    center.branches.create! name: center.name + " - " + district.name,
      status: :active,
      description: Faker::Lorem.paragraphs.join("\n"),
      address: Faker::Address.street_address,
      avatar: Faker::Avatar.image,
      district: district,
      city: district.city,
      coordinates: location[i],
      cached_avarage_rating: rand(4) + 1
  end
end

puts "Create center managers"
total_center_manager = 0
Center.find_each do |center|
  manager_count = rand(3) + 1
  manager_count.times.each do
    total_center_manager += 1
    user = User.create! email: "centermanager#{total_center_manager}@gmail.com",
      first_name: Faker::Name.first_name,
      last_name: Faker::Name.last_name,
      role: :center_manager,
      password: "123456",
      password_confirmation: "123456",
      confirmed_at: Time.zone.now
    center.center_managements.create! user: user
  end
end

centers = Center.all.includes :branches
puts "Create branch managers"
total_branch_manager = 0
centers.each do |center|
  manger_count = rand 3
  branch_count = center.branches.size
  manger_count.times.each do
    total_branch_manager += 1
    user = User.create! email: "branchmanager#{total_branch_manager}@gmail.com",
      first_name: Faker::Name.first_name,
      last_name: Faker::Name.last_name,
      role: :branch_manager,
      password: "123456",
      password_confirmation: "123456",
      confirmed_at: Time.zone.now
    center.branches.sample(rand(branch_count) + 1).each do |branch|
      user.branch_managements.create! branch: branch
    end
  end
end

puts "Creating reviews"
normal_users = User.normal_user
Branch.find_each do |branch|
  review_count = rand normal_users.size
  normal_users.sample(review_count).each do |user|
    review = branch.reviews.create! user: user,
      title: Faker::Lorem.sentence,
      content: Faker::Lorem.paragraphs.join("\n"),
      rating_criterion_1: Settings.review.rating_values.sample,
      rating_criterion_2: Settings.review.rating_values.sample,
      rating_criterion_3: Settings.review.rating_values.sample,
      rating_criterion_4: Settings.review.rating_values.sample,
      rating_criterion_5: Settings.review.rating_values.sample,
      status: Review.statuses.values.sample
    verification_status = review.verified? ? :verified : [:forwarded, :rejected].sample
    review.review_verifications.create! email: user.email,
      phone_number: Faker::PhoneNumber.cell_phone,
      status: verification_status,
      response_message: Faker::Lorem.sentence
  end
end

puts "Creating comments"
reviews = Review.verified.limit(50).includes :user, branch: :branch_managers
reviews.each do |review|
  review_count = rand 10
  review_count.times do
    if rand(2) == 0
      UserComment.create! user: normal_users.sample,
        content: Faker::Lorem.paragraph,
        review: review
    elsif branch_manager = review.branch.branch_managers.sample
      CenterComment.create! user: branch_manager,
        content: Faker::Lorem.paragraph,
        review: review,
        branch: review.branch
    end
  end
end

puts "Creating votes"
reviews.each do |review|
  vote_count = rand 10
  normal_users.sample(vote_count).each do |user|
    next if user == review.user
    Vote.create user: user,
      review: review,
      vote_type: Vote::vote_types.values.sample
  end
end
