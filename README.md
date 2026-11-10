# Materia DevOps — Gestão de Usuários

Aplicação web em **Ruby on Rails** com autenticação via **Devise** e um **CRUD de usuários**, com interface construída em HTML e CSS utilizando **Bootstrap 5**.

## Descrição do sistema

### Funcionalidades

- **Login** com e-mail e senha, opção "Lembrar de mim" e logout.
- **Recuperação de senha** ("Esqueceu sua senha?") por e-mail.
- **Acesso protegido**: todas as páginas exigem login; quem não está autenticado é redirecionado para a tela de login.
- **CRUD de usuários**:
  - Listagem em tabela com ações de visualizar, editar e excluir, e busca por nome ou e-mail;
  - Página de detalhes do usuário;
  - Cadastro e edição com validação (nome e e-mail obrigatórios, e-mail único, senha com no mínimo 6 caracteres e confirmação);
  - Na edição, deixar a senha em branco mantém a senha atual;
  - Um usuário não pode excluir a própria conta;
  - A exclusão pede confirmação.
- **Interface em português (pt-BR)** e fuso horário de Brasília.

> Não há cadastro público: novos usuários são criados apenas por quem já está logado, pela tela de Usuários.

### Tecnologias

| Item | Versão / Ferramenta |
|------|---------------------|
| Linguagem | Ruby 3.4 |
| Framework | Rails 8.1 |
| Autenticação | Devise 5 |
| Traduções | rails-i18n, devise-i18n |
| Banco de dados | PostgreSQL |
| Front-end | Bootstrap 5.3 + Bootstrap Icons (via CDN), Hotwire (Turbo/Stimulus) |
| Testes | Minitest |

### Estrutura principal

```
app/
├── controllers/
│   ├── application_controller.rb   # exige login em todas as páginas
│   └── users_controller.rb         # CRUD de usuários
├── models/
│   └── user.rb                     # modelo User (Devise + validação de nome)
├── views/
│   ├── layouts/application.html.erb  # layout com navbar e Bootstrap
│   ├── layouts/_flash.html.erb       # mensagens de sucesso/erro
│   ├── devise/                       # telas de login e recuperação de senha
│   └── users/                        # telas do CRUD (index, show, new, edit, _form)
└── assets/stylesheets/application.css  # estilos próprios
config/
├── routes.rb                       # rotas do Devise e de users
└── locales/pt-BR.yml               # nomes dos atributos em português
db/
└── seeds.rb                        # cria o usuário administrador inicial
```

### Rotas

| Método | Caminho | Ação |
|--------|---------|------|
| GET | `/users/sign_in` | Tela de login |
| DELETE | `/users/sign_out` | Logout |
| GET | `/users/password/new` | Recuperar senha |
| GET | `/` ou `/users` | Lista de usuários |
| GET | `/users/new` | Formulário de novo usuário |
| POST | `/users` | Cria usuário |
| GET | `/users/:id` | Detalhes do usuário |
| GET | `/users/:id/edit` | Formulário de edição |
| PATCH/PUT | `/users/:id` | Atualiza usuário |
| DELETE | `/users/:id` | Exclui usuário |

## Passo a passo para executar

### 1. Pré-requisitos

Tenha instalado na máquina:

- **Ruby 3.4** (recomendado instalar com [rbenv](https://github.com/rbenv/rbenv), [asdf](https://asdf-vm.com/) ou [mise](https://mise.jdx.dev/))
- **Bundler** (`gem install bundler`)
- **PostgreSQL** (servidor em execução) e suas bibliotecas de desenvolvimento
  - Ubuntu/Debian/WSL: `sudo apt install postgresql libpq-dev`
  - macOS: `brew install postgresql@18 && brew services start postgresql@18`
- **Git**
- Conexão com a internet (o Bootstrap é carregado via CDN)

Confira as versões:

```bash
ruby -v
bundle -v
psql --version
```

### 2. Clonar o repositório

```bash
git clone <url-do-repositorio>
cd materia-devops
```

### 3. Instalar as dependências

```bash
bundle install
```

### 4. Criar e preparar o banco de dados

Crie o arquivo de configuração local a partir do exemplo e ajuste usuário/senha do seu PostgreSQL:

```bash
cp .env.example .env
```

O `.env` não é versionado e é carregado automaticamente em desenvolvimento e teste.

```bash
bin/rails db:setup
```

Esse comando cria o banco, executa as migrations e roda o `db/seeds.rb`, que cria o usuário inicial.

> Se o banco já existir, use `bin/rails db:migrate` seguido de `bin/rails db:seed`.

### 5. Iniciar o servidor

```bash
bin/rails server
```

### 6. Acessar a aplicação

Abra no navegador: <http://localhost:3000>

Faça login com o usuário inicial:

| E-mail | Senha |
|--------|-------|
| `admin@example.com` | `senha123` |

> Altere a senha do administrador após o primeiro acesso, pela tela de edição do usuário.

### 7. Executar os testes

```bash
bin/rails test
```

## Comandos úteis

| Comando | Descrição |
|---------|-----------|
| `bin/rails server -p 4000` | Inicia o servidor em outra porta |
| `bin/rails console` | Abre o console do Rails |
| `bin/rails routes` | Lista todas as rotas |
| `bin/rails db:reset` | Apaga e recria o banco (com os seeds) |
| `bin/rubocop` | Verifica o estilo do código |

## Observações

- Em desenvolvimento, os e-mails (como o de recuperação de senha) não são enviados de verdade: eles são salvos como arquivos na pasta `tmp/mails/`, onde é possível abrir o link de redefinição.
- Para habilitar o cadastro público de usuários, adicione `:registerable` ao `devise` em `app/models/user.rb` e remova `skip: [:registrations]` em `config/routes.rb`.
