require "rails_helper"

RSpec.describe User, type: :model do
  let(:admin) { users(:admin) }

  def build_user(document_number:)
    User.new(nome: "New User", email: "new@example.com", password: "password123", document_number: document_number)
  end

  describe "#document_number" do
    describe "normalization" do
      it "stores only the digits when given a formatted CPF" do
        user = build_user(document_number: "111.444.777-35")
        expect(user.document_number).to eq("11144477735")
      end

      it "keeps an unformatted CPF as is" do
        user = build_user(document_number: "11144477735")
        expect(user.document_number).to eq("11144477735")
      end
    end

    describe "validations" do
      it "is valid with a valid CPF" do
        expect(build_user(document_number: "111.444.777-35")).to be_valid
      end

      it "is required" do
        user = build_user(document_number: "")
        expect(user).not_to be_valid
        expect(user.errors.details[:document_number]).to include(error: :blank)
      end

      it "is invalid when the check digits are wrong" do
        user = build_user(document_number: "111.444.777-36")
        expect(user).not_to be_valid
        expect(user.errors.details[:document_number]).to include(error: :invalid)
      end

      it "is invalid with fewer than 11 digits" do
        user = build_user(document_number: "1114447773")
        expect(user).not_to be_valid
        expect(user.errors.details[:document_number]).to include(error: :invalid)
      end

      it "is invalid with more than 11 digits" do
        user = build_user(document_number: "111444777351")
        expect(user).not_to be_valid
        expect(user.errors.details[:document_number]).to include(error: :invalid)
      end

      it "is invalid when all digits are the same" do
        user = build_user(document_number: "111.111.111-11")
        expect(user).not_to be_valid
        expect(user.errors.details[:document_number]).to include(error: :invalid)
      end

      it "must be unique, regardless of formatting" do
        user = build_user(document_number: "529.982.247-25")
        expect(user).not_to be_valid
        expect(user.errors.details[:document_number]).to include(a_hash_including(error: :taken))
      end
    end

    it "has a unique index in the database" do
      duplicate = build_user(document_number: admin.document_number)
      expect { duplicate.save!(validate: false) }.to raise_error(ActiveRecord::RecordNotUnique)
    end
  end

  describe "#formatted_document_number" do
    it "formats the CPF as 000.000.000-00" do
      expect(admin.formatted_document_number).to eq("529.982.247-25")
    end

    it "returns nil when there is no CPF" do
      expect(User.new.formatted_document_number).to be_nil
    end
  end
end
