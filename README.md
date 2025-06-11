# Wordpress na AWS

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
| SSH  |       Meu IP       |

Regras de saída:

| Tipo            |  Destino  |
| :-------------- | :-------: |
| Todo o trágfego | 0.0.0.0/0 |

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

| Tipo            |  Destino  |
| :-------------- | :-------: |
| Todo o trágfego | 0.0.0.0/0 |

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
