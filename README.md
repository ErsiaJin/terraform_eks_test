Terraform_EKS_Test
==================
> Terraform을 사용한 EKS 예시를 테스트해보고
> 사용이 편리하게 혹은 요구사항에 맞게 Terraform 코드를 수정해보는 개인 프로젝트입니다.   
****
## 1.제약사항
* 1,2,3,4의 순서대로 terraform init&apply가 수행되어야 합니다.   
  (**이전 단계에서 수행된 AWS Resource를 기반으로 수행하기 때문에, 이전 단계가 수행되지 않을 경우 정상적으로 구성되지 않습니다.**)
* 1,2,3,4의 Resource는 모두 같은 region에서 생성되어야 합니다.
* 4번 bastion EC2 생성 시 제약사항
	> 1. EKS의 kubectl을 관리할 수 있는 IAM Access 키가 사전에 생성되어야 하며, 해당 AccessKey와 SecretKey를 variable 변수로 입력해야 합니다.
	> 	* 해당 키는 EKS와 ECR에 대한 권한이 필요합니다.   
         (**상세권한 목록은 별도 확인필요, 현재는 administrator full access 권한을 부여해야 정상 동작합니다.**)
	> 2. 4번의 bastion 관련 terraform 삭제 전 아래의 명령어를 먼저 수행해야 합니다.   
         (**수행하지 않을 경우 Ingress 용 NLB와 targetgroup 자원이 삭제되지 않습니다.**)   
	```
	kubectl delete -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.5.1/deploy/static/provider/aws/deploy.yaml
	```
* Terraform destroy 수행 시 주의사항
	> 1. Terraform을 통해서 생성하지않은 AWS Resource에 대해서는 삭제를 보장하지 않습니다.   
	     따라서 destroy 수행 전 수동으로 삭제 후 Terraform destroy를 수행해야 합니다.
	> 	* 예시) Ingress 용 ELB 등   
   
&nbsp;    
## 2.각 폴더 별 역할
### 2-1.Environment
* VPC, Subnet, Route table, IGW, NAT와 같은 기본 환경을 구성합니다.
   
### 2-2.EKS
* EKS Cluster와 EKS Node Group을 구성합니다.
   
### 2-3.ECR
* docker image를 관리할 AWS ECR을 생성합니다.
   
### 2-4.EC2_bastion
* EKS를 관리할 bastion EC2 서버를 생성합니다.
* 해당 bastion에서 아래의 작업을 순차로 진행합니다.
	> 1) hostname 설정 및 yum 패키지 최신화 작업을 수행합니다.
	> 2) 기본 작업 디렉토리 생성 및 AWS IAM AcessKey 구성과 환변경수 설정을 진행합니다.
	> 3) helm 설치 및 Repository 최신화 작업을 수행합니다.
	> 4) kubectl 명령어 설치를 수행합니다.
	> 5) aws-iam-authenticator 명령어 설치를 수행합니다.
	> 6) kubectl 명령어 수행을 위한 Config 및 ConfigMap 설정을 수행합니다.
	> 7) 서비스 중계를 위해 Ingress-Nginx를 구성합니다.
	> 8) docker 명령어 설치 및 docker image를 생성하고, image를 2-3에서 생성된 ECR에 Push합니다.
	> 9) API 서비스용 pod를 생성하고 Ingress 중계규칙을 생성합니다.   
   
&nbsp; 
## 3.각 폴더 별 입력가능한 변수
변수 값은 각 폴더의 variables.tf 파일에 정의되어있습니다.
   
### 3-1.공통 변수
* default_tags : 생성한 Resource에 입력할 tag 목록을 입력합니다.
	> 기본값   
	> Project     = "dev-ihjin"   
	> Owner       = "ihjin"   
	> Environment = "development"   
	> Terraform   = "true"   
* region : Resource가 생성될 region을 설정합니다. (기본값 : ap-northeast-2)
* symbol_name : Resource의 name 등에 사용하는 symbol_name을 설정합니다. (기본값 : dev-ihjin)
   
### 3-2.Environment 폴더
* vpc_cidr : 구성할 VPC의 CIDR을 지정합니다. (기본값 : 10.0.0.0/16)
* private_subnet_a_cidr : 구성할 Private Subnet A영역의 CIDR을 지정합니다. (기본값 : 10.0.1.0/24)
* private_subnet_c_cidr : 구성할 Private Subnet C영역의 CIDR을 지정합니다. (기본값 : 10.0.2.0/24)
* public_subnet_a_cidr : 구성할 Public Subnet A영역의 CIDR을 지정합니다. (기본값 : 10.0.11.0/24)
* public_subnet_c_cidr : 구성할 Public Subnet C영역의 CIDR을 지정합니다. (기본값 : 10.0.12.0/24)
   
### 3-3.EKS 폴더
* eks_node_ami_type : eks node의 EC2 AMI type을 지정합니다. (기본값 : AL2_x86_64)
* eks_node_instance_type : eks node의 EC2 instance type을 지정합니다. (기본값 : t3.micro)
* eks_node_capacity_type : eks node의 EC2 용량 type을 지정합니다. (기본값 : ON_DEMAND)
* eks_node_volume_size : eks node의 EC2 디스크 크기를 지정합니다. (기본값 : 10, 단위는 GiB)
   
### 3-4.ECR 폴더
* 별도의 입력 변수가 없습니다.
   
### 3-5.EC2_bastion 폴더
* eks_iam_access_key : EKS를 관리할 IAM 계정의 Access Key ID를 입력합니다. (기본값 없음)
* eks_iam_secret_key : EKS를 관리할 IAM 계정의 Secret Key를 입력합니다. (기본값 없음)
	> terraform apply 시 입력창을 통해서 값을 입력할 수 있으며, 환경변수를 통해서도 설정 가능합니다.
	```
	윈도우 환경변수 설정 예시   
	set TF_VAR_eks_iam_access_key="<입력할 값>"   
	set TF_VAR_eks_iam_secret_key="<입력할 값>"   
	   
	리눅스 환경변수 설정 예시   
    export TF_VAR_eks_iam_access_key="<입력할 값>"   
    export TF_VAR_eks_iam_secret_key="<입력할 값>"   
	```
* (추가)bastion_ami : Bastion 서버 생성 시 사용할 AMI를 선택합니다.(별도 입력값 없음)   
  자동으로 Amazon Linux 2 최신버전을 가져오므로, 특정 AMI를 사용하고 싶지 않으면 수정할 필요가 없습니다.   
* bastion_instance_type : Bastion 서버의 EC2 instance type을 지정합니다. (기본값 : t3.micro)
* bastion_volume_size : Bastion 서버의 EC2 디스크 크기를 지정합니다. (기본값 : 10, 단위는 GiB)
* bastion_key_name : Bastion 서버에서 사용할 KeyPair 이름을 설정합니다. (기본값 : Ersia)
	> **해당 KeyPair는 반드시 사전에 생성되어 있어야 합니다.**
* ssh_server_port : Bastion 서버의 SSH 터미널 접속 Port를 입력합니다. (기본값 : 22)
	> **userdata-bastion.tftpl파일을 수정해서 별도로 ssh port를 변경하지 않았다면, 반드시 22번 포트로 사용해야 합니다.**   
   
&nbsp;  
## 4.사용예시
```

```  
   
&nbsp; 
## 5.참고사이트
* [VPC 모듈](https://github.com/terraform-aws-modules/terraform-aws-vpc)
* [Terraform EC2 AMI 불러오기](https://www.hashicorp.com/blog/hashicorp-terraform-supports-amazon-linux-2)
* [Terraform, Helm을 이용한 AWS EKS 구성](http://dveamer.github.io/backend/TerrafromAwsEks.html)
* [Terraform | EKS 만들어 보기](https://no-easy-dev.tistory.com/39)
* [Amazon EKS 컨트롤 영역 로깅](https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/control-plane-logs.html)
* [KUBECONFIG 환경변수](https://nayoungs.tistory.com/entry/Kubernetes-Kubeconfig)
* [EKS Control Plain Logging](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_cluster#enabling-control-plane-logging)
* [Amazon EKS 클러스터의 여러 Kubernetes 서비스에 대한 외부 액세스를 제공하려면 어떻게 해야 하나요?](https://aws.amazon.com/ko/premiumsupport/knowledge-center/eks-access-kubernetes-services/)
* [NGINX ingress controller](https://kubernetes.github.io/ingress-nginx/deploy/#network-load-balancer-nlb)
* [[NBP] Python Flask API docker image build](https://do-hansung.tistory.com/48)   
   
&nbsp; 