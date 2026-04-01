# Projeto HA com ALB - PoC

Infraestrutura em Terraform para uma arquitetura de alta disponibilidade na AWS com Load Balancer Application (ALB).

## Arquitetura

```
                    ┌─────────────────────┐
                    │   Internet Gateway  │
                    └──────────┬──────────┘
                               │
    ┌──────────────────────────▼──────────────────────────┐
    │                   VPC (10.0.0.0/16)                 │
    ├─────────────────────────────────────────────────────┤
    │  Public Subnet A (us-east-1a)                       │
    │    ┌────────────────┐                               │
    │    │   NAT Instance │                               │
    │    └────────┬───────┘                               │
    │             │                                       │
    │  Private Subnet A (us-east-1a)                      │
    │    ┌────────────────────────────────┐              │
    │    │   ALB Security Group           │              │
    │    │   ┌────────────────────────┐   │              │
    │    │   │   Application ASG      │   │              │
    │    │   │   - Instance 1         │   │              │
    │    │   │   - Instance 2         │   │              │
    │    │   │   - Instance 3 (max)   │   │              │
    │    │   └────────────────────────┘   │              │
    │    └────────────────────────────────┘              │
    │                                                     │
    │  Private Subnet B (us-east-1b)                      │
    │    ┌────────────────────────────────┐              │
    │    │   Application ASG (same as above)             │
    │    └────────────────────────────────┘              │
    └─────────────────────────────────────────────────────┘
```

## Estrutura do Projeto

```
projeto-2-HA/
├── main.tf                 # Ponto de entrada principal
├── variables.tf            # Variáveis de configuração com validação
├── outputs.tf              # Outputs da infraestrutura
├── provider.tf             # Provider e backend (original)
├── aws_codes.sh            # Script de criação de recursos AWS
├── keys.tf                 # Key pair (original)
├── .gitignore
└── modules/
    ├── vpc/                # Módulo VPC e subnets
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── security_groups/    # Módulo Security Groups
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── loadbalancer/       # Módulo ALB e Target Group
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    └── instances/          # Módulo NAT, ASG, IAM
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

## Pré-requisitos

- Terraform >= 1.0.0
- AWS CLI configurado com credenciais
- Chave SSH pública em `~/.ssh/projeto-aws-key.pub`

## Como Usar

### 1. Configurar Backend S3 (DynamoDB + S3)

Antes de rodar o Terraform, crie os recursos de backend:

```bash
# Criar bucket S3 para state file
aws s3api create-bucket \
    --bucket tf-state-bucket-ACCOUNT-ID-us-east-1-an \
    --region us-east-1

# Habilitar versionamento
aws s3api put-bucket-versioning \
    --bucket tf-state-bucket-ACCOUNT-ID-us-east-1-an \
    --versioning-configuration Status=Enabled

# Habilitar encryption
aws s3api put-bucket-encryption \
    --bucket tf-state-bucket-ACCOUNT-ID-us-east-1-an \
    --server-side-encryption-configuration '{
        "Rules": [
            {"ApplyServerSideEncryptionByDefault": {"SSEAlgorithm": "AES256"}}
        ]
    }'

# Bloquear acesso público
aws s3api put-public-access-block \
    --bucket tf-state-bucket-ACCOUNT-ID-us-east-1-an \
    --public-access-block-configuration "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"

# Criar tabela DynamoDB para locking
aws dynamodb create-table \
    --table-name terraform-state-lock \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
    --region us-east-1
```

### 2. Inicializar e Aplicar

```bash
# Inicializar Terraform
terraform init

# Verificar o plano
terraform plan

# Aplicar
terraform apply
```

### 3. Limpar Recursos

```bash
terraform destroy
```

## Variáveis Configuráveis

| Variável | Descrição | Default |
|----------|-----------|---------|
| `aws_region` | Região AWS | us-east-1 |
| `project_name` | Nome do projeto para tags | projeto-ha |
| `environment` | Ambiente (dev/staging/prod) | dev |
| `name_prefix` | Prefixo para recursos | projeto-ha |
| `vpc_cidr` | CIDR da VPC | 10.0.0.0/16 |
| `app_port` | Porta da aplicação | 8080 |
| `app_instance_type` | Tipo da instância da app | t3.micro |
| `nat_instance_type` | Tipo da instância NAT | t3.micro |
| `desired_capacity` | Capacidade desejada do ASG | 2 |
| `max_size` | Tamanho máximo do ASG | 3 |
| `min_size` | Tamanho mínimo do ASG | 1 |
| `deletion_protection` | Proteção de exclusão do ALB | true |

## Output Importante

Após o `apply`, o output `alb_dns_name` conterá o DNS do Load Balancer para acessar a aplicação:

```bash
terraform output alb_dns_name
# http://<dns-name>.us-east-1.elb.amazonaws.com
```

## Melhorias Futuras

- [ ] Adicionar Auto Scaling Policies (scale-in/scale-out)
- [ ] Configurar Target Group health check com porta específica
- [ ] Adicionar SSL/TLS com Certificate Manager
- [ ] Criar records Route53 para domains personalizados
- [ ] Adicionar WAF para proteção da aplicação
- [ ] Implementar logs do ALB no S3
- [ ] Adicionar SNS notifications para eventos do ASG
- [ ] Support para múltiplos ambientes (prod, staging, etc)
