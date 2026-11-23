require "rails_helper"

RSpec.describe UsersController, type: :controller do
  let(:admin) { users(:admin) }
  let(:maria) { users(:maria) }

  let(:valid_attributes) do
    { nome: "New User", email: "new@example.com", document_number: "111.444.777-35",
      password: "password123", password_confirmation: "password123" }
  end
  let(:invalid_attributes) do
    { nome: "", email: "invalid", document_number: "123", password: "1", password_confirmation: "2" }
  end

  context "when not authenticated" do
    it "redirects to the login page" do
      get :index
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  context "when authenticated" do
    before { sign_in admin }

    describe "GET #index" do
      it "renders the list with all users ordered by name" do
        get :index
        expect(response).to have_http_status(:ok)
        expect(response).to render_template(:index)
        expect(assigns(:users)).to eq([ admin, maria ])
      end

      it "filters by the search term and stores it without surrounding spaces" do
        get :index, params: { q: "  maria  " }
        expect(assigns(:query)).to eq("maria")
        expect(assigns(:users)).to eq([ maria ])
      end
    end

    describe "GET #show" do
      it "loads the requested user" do
        get :show, params: { id: maria.id }
        expect(response).to render_template(:show)
        expect(assigns(:user)).to eq(maria)
      end

      it "raises an error when the user does not exist" do
        expect { get :show, params: { id: 0 } }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    describe "GET #new" do
      it "builds a new user" do
        get :new
        expect(response).to render_template(:new)
        expect(assigns(:user)).to be_a_new(User)
      end
    end

    describe "GET #edit" do
      it "loads the user for editing" do
        get :edit, params: { id: maria.id }
        expect(response).to render_template(:edit)
        expect(assigns(:user)).to eq(maria)
      end
    end

    describe "POST #create" do
      context "with valid params" do
        it "creates the user and redirects to it" do
          expect {
            post :create, params: { user: valid_attributes }
          }.to change(User, :count).by(1)

          expect(response).to redirect_to(User.last)
          expect(flash[:notice]).to eq("Usuário criado com sucesso.")
        end

        it "saves the document number with digits only" do
          post :create, params: { user: valid_attributes }
          expect(User.last.document_number).to eq("11144477735")
        end
      end

      context "with an invalid document number" do
        it "does not create the user and re-renders the form" do
          expect {
            post :create, params: { user: valid_attributes.merge(document_number: "111.444.777-00") }
          }.not_to change(User, :count)

          expect(response).to have_http_status(:unprocessable_content)
          expect(assigns(:user).errors[:document_number]).to be_present
        end
      end

      context "with a document number already in use" do
        it "does not create the user" do
          expect {
            post :create, params: { user: valid_attributes.merge(document_number: maria.formatted_document_number) }
          }.not_to change(User, :count)

          expect(response).to have_http_status(:unprocessable_content)
        end
      end

      context "with invalid params" do
        it "does not create the user and re-renders the form" do
          expect {
            post :create, params: { user: invalid_attributes }
          }.not_to change(User, :count)

          expect(response).to have_http_status(:unprocessable_content)
          expect(response).to render_template(:new)
        end
      end
    end

    describe "PATCH #update" do
      context "with valid params" do
        it "updates the user and redirects to it" do
          patch :update, params: { id: maria.id, user: { nome: "Maria Edited" } }

          expect(maria.reload.nome).to eq("Maria Edited")
          expect(response).to redirect_to(maria)
          expect(flash[:notice]).to eq("Usuário atualizado com sucesso.")
        end

        it "updates the document number" do
          patch :update, params: { id: maria.id, user: { document_number: "935.411.347-80" } }
          expect(maria.reload.document_number).to eq("93541134780")
        end

        it "keeps the current password when it is left blank" do
          patch :update, params: { id: maria.id, user: { nome: "Maria", password: "", password_confirmation: "" } }
          expect(maria.reload.valid_password?("password123")).to be(true)
        end

        it "changes the password when one is provided" do
          patch :update, params: { id: maria.id, user: { password: "newPassword1", password_confirmation: "newPassword1" } }
          expect(maria.reload.valid_password?("newPassword1")).to be(true)
        end

        it "keeps the user signed in after changing their own password" do
          patch :update, params: { id: admin.id, user: { password: "newPassword1", password_confirmation: "newPassword1" } }
          expect(controller.current_user).to eq(admin)
        end
      end

      context "with invalid params" do
        it "does not update the user and re-renders the edit form" do
          patch :update, params: { id: maria.id, user: { nome: "" } }

          expect(maria.reload.nome).to eq("Maria Test")
          expect(response).to have_http_status(:unprocessable_content)
          expect(response).to render_template(:edit)
        end

        it "does not update with an invalid document number" do
          patch :update, params: { id: maria.id, user: { document_number: "000.000.000-00" } }

          expect(maria.reload.document_number).to eq("12345678909")
          expect(response).to have_http_status(:unprocessable_content)
        end
      end
    end

    describe "DELETE #destroy" do
      it "deletes another user and redirects to the list" do
        expect {
          delete :destroy, params: { id: maria.id }
        }.to change(User, :count).by(-1)

        expect(response).to redirect_to(users_path)
        expect(response).to have_http_status(:see_other)
        expect(flash[:notice]).to eq("Usuário excluído com sucesso.")
      end

      it "does not allow users to delete themselves" do
        expect {
          delete :destroy, params: { id: admin.id }
        }.not_to change(User, :count)

        expect(response).to redirect_to(users_path)
        expect(flash[:alert]).to eq("Você não pode excluir o próprio usuário.")
      end
    end
  end
end
