# Digital Product Bootcamp
Projeto da matéria de "Digital Product - Bootcamp" do MBA "Cloud & DevOps" da Faculdade Impacta.

**Tema:** Criação de uma esteira no Jenkins para provisionamento de recursos na AWS utilizando Terraform e configuração/construção de um cluster Red-Hat JBOSS rodando com quatro nodes através do Ansible

## Pré-Requisitos
1. Credenciais AWS
2. Acesso ao instalador JBOSS EAP (Esse instalador estará disponível em um S3 Privado que será criado anteriormente, fora da estrutura do Projeto)


## Provisionamento da Infra - Terraform
Iremos criar módulos Terraform para provisionamento da Infraestrutura do Projeto, segmentado conforme abaixo:
1. Network
    - 01 VPC
    - 02 Subnets Privadas
    - 02 Subnets Públicas
    - Nat Gateway
    - Security Group
2. Compute
    - EC2 para o Jenkins
    - EC2 para os
    - Elastic IP para acesso aos recursos

## Configuração do Ambiente - Ansible

Iremos criar um playbook com algumas rols para instalação do Red Hat JBOSS Enterprise Application Platform e configuração do mesmo no modo `domain`, para utilização em um cluster com alta disponibilidade.

Roles:
1. Instalando Pré-Requisitos
2. Instalando o JBOSS
3. Configurar o Domain Controller
4. Adicionar os Nodes no Dominio