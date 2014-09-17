require 'rails_helper'

describe Api::V1::UserExpectationController do

  describe "#index" do
    login_student

    let(:student) { subject.current_user }

    it "returns 200 with all user's expectations and creates any that don't exist" do
      exp1 = create(:expectation, title: "Expectation 1", organization_id: student.organization_id)
      exp2 = create(:expectation, title: "Expectation 2", organization_id: student.organization_id)
      create(:user_expectation, expectation_id: exp1.id, user_id: student.id)

      db_user_expectations = UserExpectation.where(:user_id => student.id)
      expect(db_user_expectations.length).to eq(1)

      get :index, {:user_id => student.id}

      db_user_expectations = UserExpectation.where(:user_id => student.id)
      expect(db_user_expectations.length).to eq(2)

      expect(response.status).to eq(200)
      expect(json["user_expectations"].length).to eq(2)

    end
  end

  describe "#show" do
    login_student

    let(:student) { subject.current_user }

    it "returns 200 with the user_expectation domain object with expectation object properties" do
      expectation = create(:expectation, title: "Expectation 1", organization_id: student.organization_id)
      user_expectation = create(:user_expectation, expectation_id: expectation.id, user_id: student.id, status: 2)

      get :show, {:id => user_expectation.id}

      expect(response.status).to eq(200)
      expect(json["user_expectation"]["id"]).to eq(user_expectation.id)
      expect(json["user_expectation"]["expectation_id"]).to eq(user_expectation.expectation_id)
      expect(json["user_expectation"]["user_id"]).to eq(user_expectation.user_id)
      expect(json["user_expectation"]["status"]).to eq(user_expectation.status)
      expect(json["user_expectation"]["comment"]).to eq(user_expectation.comment)
      expect(json["user_expectation"]["title"]).to eq(expectation.title)
      expect(json["user_expectation"]["description"]).to eq(expectation.description)
      expect(json["user_expectation"]["rank"]).to eq(expectation.rank)
    end
  end

  describe "#update" do
    login_mentor

    let(:current_user) { subject.current_user }
    let(:student) { create(:student) }

    it "returns 200 and updates user_expectation" do
      expectation = create(:expectation, title: "Expectation 1", organization_id: student.organization_id)
      user_expectation = create(:user_expectation, expectation_id: expectation.id, user_id: student.id, status: 2, comment: "Hello")

      history_before_length = UserExpectationHistory.where(:user_expectation_id => user_expectation.id).length

      updated_expectation = attributes_for(:user_expectation, status: 0, comment: "Bye")
      put :update, {:id => user_expectation.id, :userExpectation => updated_expectation}

      history_after_length = UserExpectationHistory.where(:user_expectation_id => user_expectation.id).length

      expect(response.status).to eq(200)
      expect(json["user_expectation"]["status"]).to eq(0)
      expect(json["user_expectation"]["modified_by_id"]).to eq(current_user.id)
      expect(json["user_expectation"]["modified_by_name"]).to eq(current_user.full_name)
      expect(json["user_expectation"]["status"]).to eq(0)
      expect(json["user_expectation"]["comment"]).to eq("Bye")
      expect(history_after_length).to eq(history_before_length + 1)
    end
  end

end
