require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @admin = users(:admin)
    @other = users(:maria)
  end

  test "redireciona para o login sem autenticação" do
    get users_url
    assert_redirected_to new_user_session_url
  end

  test "exibe a tela de login" do
    get new_user_session_url
    assert_response :success
    assert_select "input[type=email]"
  end

  test "faz login com credenciais válidas" do
    post user_session_url, params: { user: { email: @admin.email, password: "senha123" } }
    assert_redirected_to root_url
  end

  test "lista usuários" do
    sign_in @admin
    get users_url
    assert_response :success
    assert_select "td", text: /Maria Teste/
  end

  test "filtra usuários pelo nome sem diferenciar maiúsculas" do
    sign_in @admin
    get users_url, params: { q: "maria" }
    assert_response :success
    assert_select "a", text: "Maria Teste"
    assert_select "a", text: "Administrador", count: 0
  end

  test "filtra usuários pelo e-mail" do
    sign_in @admin
    get users_url, params: { q: "admin@example" }
    assert_response :success
    assert_select "a", text: "Administrador"
    assert_select "a", text: "Maria Teste", count: 0
  end

  test "informa quando a busca não encontra usuários" do
    sign_in @admin
    get users_url, params: { q: "inexistente" }
    assert_response :success
    assert_select "p", text: /Nenhum usuário encontrado/
    assert_select "table", count: 0
  end

  test "trata curingas da busca como texto literal" do
    sign_in @admin
    get users_url, params: { q: "%" }
    assert_response :success
    assert_select "p", text: /Nenhum usuário encontrado/
  end

  test "cria usuário" do
    sign_in @admin
    assert_difference("User.count", 1) do
      post users_url, params: { user: { nome: "Novo", email: "novo@example.com",
                                        password: "senha123", password_confirmation: "senha123" } }
    end
    assert_redirected_to user_url(User.last)
  end

  test "não cria usuário inválido" do
    sign_in @admin
    assert_no_difference("User.count") do
      post users_url, params: { user: { nome: "", email: "x", password: "1", password_confirmation: "2" } }
    end
    assert_response :unprocessable_content
  end

  test "atualiza usuário mantendo a senha quando em branco" do
    sign_in @admin
    patch user_url(@other), params: { user: { nome: "Maria Editada", email: @other.email, password: "", password_confirmation: "" } }
    assert_redirected_to user_url(@other)
    @other.reload
    assert_equal "Maria Editada", @other.nome
    assert @other.valid_password?("senha123")
  end

  test "exclui usuário" do
    sign_in @admin
    assert_difference("User.count", -1) do
      delete user_url(@other)
    end
    assert_redirected_to users_url
  end

  test "não permite excluir o próprio usuário" do
    sign_in @admin
    assert_no_difference("User.count") do
      delete user_url(@admin)
    end
  end
end
