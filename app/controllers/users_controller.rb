class UsersController < ApplicationController
  before_action :set_user, only: %i[show edit update destroy]

  def index
    @users = User.order(:nome)
  end

  def show
  end

  def new
    @user = User.new
  end

  def edit
  end

  def create
    @user = User.new(user_params)

    if @user.save
      redirect_to @user, notice: "Usuário criado com sucesso."
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    attrs = user_params
    # Senha em branco na edição = manter a senha atual
    if attrs[:password].blank?
      attrs.delete(:password)
      attrs.delete(:password_confirmation)
    end

    if @user.update(attrs)
      bypass_sign_in(@user) if @user == current_user
      redirect_to @user, notice: "Usuário atualizado com sucesso."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    if @user == current_user
      redirect_to users_path, alert: "Você não pode excluir o próprio usuário."
    else
      @user.destroy!
      redirect_to users_path, notice: "Usuário excluído com sucesso.", status: :see_other
    end
  end

  private

  def set_user
    @user = User.find(params.expect(:id))
  end

  def user_params
    params.expect(user: %i[nome email password password_confirmation])
  end
end
