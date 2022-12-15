# Terraform_eks_test
기존에 제공하는 Terraform을 사용한 EKS 예시를 테스트해보고
사용이 편리하게 혹은 본인의 요구사항에 맞게 Terraform 코드를 수정해보는 개인 프로젝트입니다.

## 제약사항
* 사전에 bastion EC2에서 사용할 키가 생성되어있어야 하며, 해당 키를 variable 변수로 입력해야 합니다.
* 1,2,3,4의 순서대로 terraform init&apply가 수행되어야 합니다.(사전에 수행된 AWS Resource를 기반으로 수행하기에 이전 단계가 수행되지 않을 경우 정상적으로 구성되지 않습니다.)
* 3번의 bastion 생성 시 EKS의 kubectl을 관리할 수 있는 AWS AccessKey 변수 입력이 필요합니다.

## 사용을 위한 입력 변수


### 대략적인 구조

``` aaa
1.environment
  - vpc, subnet, route table과 같은 기본 환경을 구성합니다.
  
2.eks
  - eks cluster와 eks node group을 구성합니다.
  
3.ec2_bastion
  - eks를 관리할 bastion EC2 서버를 생성하고, kubectl, helm 등 기본 명령어 세팅을 진행합니다.

4.service
  - ingress controler설치와 ecr 구성 및 pod 구성을 진행합니다.
  -> ingress를 별도로 빼는게 낫는가?
```

## 사용예시
``` aaa
사용 예시 설명
```

## 참고사이트
* [Terraform, Helm을 이용한 AWS EKS 구성](http://dveamer.github.io/backend/TerrafromAwsEks.html)
* [Terraform | EKS 만들어 보기](https://no-easy-dev.tistory.com/39)
* [Amazon EKS 컨트롤 영역 로깅](https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/control-plane-logs.html)