# Digital Product Bootcamp
Projeto da matéria de "Digital Product - Bootcamp" do MBA "Cloud & DevOps" da Faculdade Impacta.

**Tema:** Criação de código para provisionamento de recursos na AWS utilizando Terraform e configuração/construção de um cluster Red-Hat JBOSS rodando com quatro nodes através do Ansible acionados via `Provisioner`, do Terraform

## Pré-Requisitos
1. Credenciais AWS
2. Acesso ao instalador JBOSS EAP (Esse instalador estará disponível em um S3 Privado que será criado anteriormente, fora da estrutura do Projeto)
3. Chave SSH para acesso aos servidores


## Provisionamento da Infra - Terraform
Iremos criar módulos Terraform para provisionamento da Infraestrutura do Projeto, segmentado conforme abaixo:
1. Network
    - 01 VPC
    - 02 Subnets Privadas
    - 02 Subnets Públicas
    - Nat Gateway
    - Security Group
2. Compute
    - EC2 para o Bastion
    - EC2 para os Servidores JBOSS
    - Elastic IP para acesso aos recursos
    - Application Load Balancing para acesso à console do JBOSS

## Configuração do Ambiente - Ansible

Iremos criar um playbook com algumas rols para instalação do Red Hat JBOSS Enterprise Application Platform e configuração do mesmo no modo `domain`, para utilização em um cluster com alta disponibilidade.

Roles:
1. Download de Pré-Requisitos
2. Instalando Pré-Requisitos
3. Instalando o JBOSS
4. Configurar o Domain Controller
5. Adicionar os Nodes no Dominio
