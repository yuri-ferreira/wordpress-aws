# Wordpress na AWS

![visão geral arquitetura](/imgs/arquitetura.png)

Para esse projeto foi solicitado uma aplicação Wordpress rodando via Docker em alta disponibilidade seguindo a arquitetura acima na AWS.

### Objetivos

---

1. Instalação e configuração do DOCKER ou
   CONTAINERD no host EC2 (utilizar user_data.sh);
2. Efetuar Deploy de uma aplicação
   Wordpress com:
   container de aplicação
   RDS database Mysql
3. Configuração da utilização do serviço
   EFS AWS para estáticos do container de
   aplicação Wordpress
4. Configuração do serviço de Load
   Balancer AWS para a aplicação
   Wordpress

### Pontos importantes

---

1. Não utilizar ip público para saída do
   serviços WP (Evitem publicar o serviço
   WP via IP Público)
2. Sugestão para o tráfego de internet
   sair pelo LB (Load Balancer Classic)
3. Pastas públicas e estáticos do
   wordpress sugestão de utilizar o
   EFS (Elastic File Sistem)
4. Fica a critério de cada integrante
   usar Dockerfile ou
   Dockercompose;
5. Necessário demonstrar a aplicação
   wordpress funcionando (tela de
   login)
6. Aplicação Wordpress precisa estar
   rodando na porta 80 ou 8080;
7. Utilizar repositório git para
   versionamento;
   Criar documentação.

## 1. Criar VPC

![visão geral VPC](/imgs/VPC.png)

**_Importantes_:**

Bloco CIDR : 10.0.0.0/16

Gateway NAT : 1 por AZ

Endpoints da VPC: Nenhum

Habilitar nomes de host DNS : Ativado

Habilitar resolução de DNS : Ativado

## 2. Configurando Security Groups

**EC2**

Regras de entrada:

| Tipo |       Origem       |
| :--- | :----------------: |
| HTTP | Security Group ALB |

Regras de saída:

| Tipo         |        Destino        |
| :----------- | :-------------------: |
| MySQL/Aurora | Security Group do RDS |
| NFS          | Security Group do EFS |
| HTTP         |       0.0.0.0/0       |

---

**RDS**

Regras de entrada:

| Tipo         |       Origem       |
| :----------- | :----------------: |
| MySQL/Aurora | Security Group EC2 |

Regras de saída:

| Tipo            |  Destino  |
| :-------------- | :-------: |
| Todo o trágfego | 0.0.0.0/0 |

---

**EFS**

Regras de entrada:

| Tipo |       Origem       |
| :--- | :----------------: |
| NFS  | Security Group EC2 |

Regras de saída:

| Tipo            |  Destino  |
| :-------------- | :-------: |
| Todo o trágfego | 0.0.0.0/0 |

---

**ALB**

Regras de entrada:

| Tipo |  Origem   |
| :--- | :-------: |
| HTTP | 0.0.0.0/0 |

Regras de saída:

| Tipo |      Destino       |
| :--- | :----------------: |
| HTTP | Security Group EC2 |

## 3. Criar e configurar RDS (MySQL)

Versão MySQL 8.0.41

![visão geral VPC](/imgs/RDS.png)

É necessário definir nome de usuário e senha para acesso do banco de dados.

Foi utilizado a instância **db.t3.micro**.

É necessário também conectar na VPC criada e definir o grupo de segurança criado anteriormente para o RDS.

**Importante:**

Deve-se marcar a **"No"** para a opção **"Public Access"**;

Em **"Configuração adicional"**, definir um nome do banco de dados inicial.

## 4. Criar e configurar EFS

![visão geral VPC](/imgs/EFS.png)

Selecione a VPC criada anteriormente

**Importante:**

Definir as redes do "Destino de montagem" para as privadas da VPC.

## 5. Criar e configurar o Launch Template

É importante retirar o IP Público, utilizar o grupo de segurança criado anteriormente e definir a t2.micro com o AMI Amazon Linux 2023.

![visão geral Launch Template](/imgs/LT.png)

Não é definido as subnets pois isso será trabalho do Auto Scaling Group.

Após, deve-se criar um [user_data](/user_data.sh) e associá-lo ao modelo de execução.

## 6. Criar e configurar o Load Balancer

Será criado um ALB (Application Load Balance), que deve ser voltado para internet.

Em **"Listeners e roteamento"**, deve-se criar um Target Group.

![visão do Listeners e roteamento](/imgs/listeners.png)

### 6.5 Criar e configurar um Target Group

Seu **tipo de destino** será **"Instâncias"**, com um protocolo **HTTP** (Com sua versão HTTP1)para a porta **80**, o caminho da verificação de integridade será o padrão.

![visão do verificação de integridade](/imgs/health.png)

## 7. Criar e configurar o Auto Scaling Group

Será utilizado o modelo de execução criado anteriormente.

![visão geral do Auto Scaling Group](/imgs/atg.png)

Em Rede, será escolhida a VPC do projeto e as sub-redes privadas criadas anteriormente.

![visão geral do Auto Scaling Group_redes](/imgs/redes_atg.png)

Em Balanceamento de carga, deve-se anexar o ALB criado anteriormente junto com o Target Group.

![visão geral do Auto Scaling Group_loadbalancer](/imgs/lb_atg.png)

Em Tamanho do grupo e Escalabilidade, será definido:

**Capacidade desejada:** 2

**Capacidade mínima desejada:** 2

**Capacidade máxima desejada:** 4

Para que assim tenha uma alta disponibilidade com base nos acessos é criado também:

**Política de escalabilidade**, que com base nos requests poderá diminuir ou aumentar a quantidade de instâncias.

![visão geral do Auto Scaling Group_tamanho](/imgs/tamanho_atg.png)

## 8. Wordpress em alta disponibilidade

Com tudo configurado, basta aguardar o Auto Scaling Group criar as instâncias.

Após alguns minutos é possível visualiza-las:

![visão geral EC2](/imgs/EC2s.png)

E assim é possível acessar o Wordpress utilizando o DNS do Load Balancer.

![visão geral Wordpress](/imgs/Wordpress.png)
