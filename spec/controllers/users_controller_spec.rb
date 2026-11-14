require "rails_helper"

RSpec.describe UsersController, type: :controller do
  let(:admin) { users(:admin) }
  let(:maria) { users(:maria) }

  let(:valid_attributes) do
    { nome: "Novo Usuário", email: "novo@example.com", password: "senha123", password_confirmation: "senha123" }
  end
  let(:invalid_attributes) do
    { nome: "", email: "invalido", password: "1", password_confirmation: "2" }
  end

  context "sem autenticação" do
    it "redireciona para o login" do
      get :index
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  context "com usuário autenticado" do
    before { sign_in admin }

    describe "GET #index" do
      it "renderiza a listagem com todos os usuários ordenados por nome" do
        get :index
        expect(response).to have_http_status(:ok)
        expect(response).to render_template(:index)
        expect(assigns(:users)).to eq([ admin, maria ])
      end

      it "filtra pelo termo de busca e guarda a busca sem espaços" do
        get :index, params: { q: "  maria  " }
        expect(assigns(:query)).to eq("maria")
        expect(assigns(:users)).to eq([ maria ])
      end
    end

    describe "GET #show" do
      it "carrega o usuário solicitado" do
        get :show, params: { id: maria.id }
        expect(response).to render_template(:show)
        expect(assigns(:user)).to eq(maria)
      end

      it "levanta erro quando o usuário não existe" do
        expect { get :show, params: { id: 0 } }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    describe "GET #new" do
      it "inicializa um novo usuário" do
        get :new
        expect(response).to render_template(:new)
        expect(assigns(:user)).to be_a_new(User)
      end
    end

    describe "GET #edit" do
      it "carrega o usuário para edição" do
        get :edit, params: { id: maria.id }
        expect(response).to render_template(:edit)
        expect(assigns(:user)).to eq(maria)
      end
    end

    describe "POST #create" do
      context "com parâmetros válidos" do
        it "cria o usuário e redireciona para ele" do
          expect {
            post :create, params: { user: valid_attributes }
          }.to change(User, :count).by(1)

          expect(response).to redirect_to(User.last)
          expect(flash[:notice]).to eq("Usuário criado com sucesso.")
        end
      end

      context "com parâmetros inválidos" do
        it "não cria o usuário e renderiza o formulário novamente" do
          expect {
            post :create, params: { user: invalid_attributes }
          }.not_to change(User, :count)

          expect(response).to have_http_status(:unprocessable_content)
          expect(response).to render_template(:new)
        end
      end
    end

    describe "PATCH #update" do
      context "com parâmetros válidos" do
        it "atualiza o usuário e redireciona para ele" do
          patch :update, params: { id: maria.id, user: { nome: "Maria Editada" } }

          expect(maria.reload.nome).to eq("Maria Editada")
          expect(response).to redirect_to(maria)
          expect(flash[:notice]).to eq("Usuário atualizado com sucesso.")
        end

        it "mantém a senha atual quando enviada em branco" do
          patch :update, params: { id: maria.id, user: { nome: "Maria", password: "", password_confirmation: "" } }
          expect(maria.reload.valid_password?("senha123")).to be(true)
        end

        it "altera a senha quando informada" do
          patch :update, params: { id: maria.id, user: { password: "novaSenha1", password_confirmation: "novaSenha1" } }
          expect(maria.reload.valid_password?("novaSenha1")).to be(true)
        end

        it "mantém o usuário logado ao alterar a própria senha" do
          patch :update, params: { id: admin.id, user: { password: "novaSenha1", password_confirmation: "novaSenha1" } }
          expect(controller.current_user).to eq(admin)
        end
      end

      context "com parâmetros inválidos" do
        it "não atualiza e renderiza o formulário de edição" do
          patch :update, params: { id: maria.id, user: { nome: "" } }

          expect(maria.reload.nome).to eq("Maria Teste")
          expect(response).to have_http_status(:unprocessable_content)
          expect(response).to render_template(:edit)
        end
      end
    end

    describe "DELETE #destroy" do
      it "exclui outro usuário e redireciona para a listagem" do
        expect {
          delete :destroy, params: { id: maria.id }
        }.to change(User, :count).by(-1)

        expect(response).to redirect_to(users_path)
        expect(response).to have_http_status(:see_other)
        expect(flash[:notice]).to eq("Usuário excluído com sucesso.")
      end

      it "não permite excluir o próprio usuário" do
        expect {
          delete :destroy, params: { id: admin.id }
        }.not_to change(User, :count)

        expect(response).to redirect_to(users_path)
        expect(flash[:alert]).to eq("Você não pode excluir o próprio usuário.")
      end
    end
  end
end
