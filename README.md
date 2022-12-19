# Terraform_eks_test
기존에 제공하는 Terraform을 사용한 EKS 예시를 테스트해보고
사용이 편리하게 혹은 요구사항에 맞게 Terraform 코드를 수정해보는 개인 프로젝트입니다.  



## 제약사항
* 1,2,3,4의 순서대로 terraform init&apply가 수행되어야 합니다.(이전 단계에서 수행된 AWS Resource를 기반으로 수행하기에 이전 단계가 수행되지 않을 경우 정상적으로 구성되지 않습니다.)
* 1,2,3,4의 Resource는 모두 같은 region에서 생성되어야 합니다.
* 4번 bastion EC2 생성 시 제약사항
  1. EKS의 kubectl을 관리할 수 있는 IAM Access 키가 사전에 생성되어야 하며, 해당 AccessKey와 SecretKey를 variable 변수로 입력해야 합니다.
    - 해당 키는 EKS와 ECR에 대한 권한이 필요합니다. (상세권한 목록은 별도 확인필요, 현재는 administrator full access 권한을 부여해야 정상 동작합니다.)
  2. 4번의 bastion 관련 terraform 삭제 전 아래의 명령어를 먼저 수행해야 합니다. (수행하지 않을 경우 ingress 용 NLB와 targetgroup 자원이 삭제되지 않습니다.)
    - kubectl delete -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.5.1/deploy/static/provider/aws/deploy.yaml
* 삭제 시 주의사항
  1. Terraform을 통해서 생성하지않은 AWS Resource에 대해서는 삭제를 보장하지 않습니다.
    - 예시) ingress 용 ELB 등  



## 사용을 위한 입력 변수
변수 값은 각 폴더의 variables.tf 파일에 명시되어있습니다.
``` input variable
0.공통
  - 생성한 Resource에 입력할 tag 목록을 입력합니다. (default 값이 설정되어있습니다.)
  - Resource의 name 등에 사용하는 symbol_name을 설정합니다. (default 값이 설정되어있습니다.)
  - Resource가 생성될 region을 설정합니다. (default 값이 설정되어있습니다.)

1.environment
  - vpc, subnet의 cidr을 variables.tf 파일에 입력합니다. (default 값이 설정되어있습니다.)
  
2.eks
  - eks node의 EC2 AMI type, instance type, capacity type, disk 크기를 입력합니다.

3.ecr
  - docker image를 관리할 aws ecr을 생성합니다.

4.ec2_bastion 생성 시 아래의 변수 입력이 필요합니다.
  - eks를 관리할 IAM 계정의 access key와 secret key를 입력해야 합니다.
     * 환경변수를 통해서도 terraform apply 전에 설정할 수 있습니다.
	 * 윈도우 예시
	   set TF_VAR_eks_iam_access_key="<입력할 값>"
	   set TF_VAR_eks_iam_secret_key="<입력할 값>"
	   
	 * 리눅스 예시
	   export TF_VAR_eks_iam_access_key="<입력할 값>"
	   export TF_VAR_eks_iam_secret_key="<입력할 값>"
  - Bastion 서버의 EC2 instance type 과 디스크 크기를 입력합니다.
  - Bastion 서버의 AMI 타입은 Amazon Linux 2의 최신버전을 자동으로 선택합니다.
  - Bastion 서버에서 사용할 KeyPair 이름을 입력해야 합니다. (**해당 KeyPair는 사전에 미리 생성되어 있어야 합니다.)
  - Bastion 서버의 SSH 터미널 접속 Port를 입력해야 합니다. (**별도로 user data를 통해 별도로 ssh port를 변경하지 않았을 경우, 반드시 22번 포트로 사용해야 합니다.)
```  



## 대략적인 구조
``` explan architecture
1.environment
  - vpc, subnet, route table과 같은 기본 환경을 구성합니다.
  
2.eks
  - eks cluster와 eks node group을 구성합니다.

3.ecr
  - docker image를 관리할 aws ecr을 생성합니다.
  
4.ec2_bastion
  - eks를 관리할 bastion EC2 서버를 생성합니다.
  - 해당 bastion에서 아래의 작업을 순차로 진행합니다.
    1) kubectl, helm 등 기본 명령어와 환변경수 설정을 진행합니다.
	2) ingress-nginx NLB를 구성합니다.
	3) docker image를 생성하고 ecr에 push합니다.
	4) push한 image를 바탕으로 api 서비스 pod를 생성하고 ingress 중계규칙을 생성합니다.
```  



## 사용예시
``` use example
사용 예시 설명 작성 필요~~
```  



## 참고사이트
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
